/// Простой прокси-сервер для веб-версии Flutter приложения
/// 
/// Этот сервер принимает запросы от веб-приложения и проксирует их
/// через указанный HTTP/HTTPS прокси к API сервисам.

const express = require('express');
const fetch = require('node-fetch');
const { HttpsProxyAgent } = require('https-proxy-agent');
const { SocksProxyAgent } = require('socks-proxy-agent');
const cors = require('cors');

const app = express();
const PORT = 3001;

// Middleware with enhanced mobile support
app.use(cors({
  origin: true, // Allow all origins for mobile compatibility
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'X-Proxy-URL', 'X-Proxy-Host', 'X-Proxy-Port', 'X-Proxy-User', 'X-Proxy-Pass'],
  exposedHeaders: ['Content-Length', 'Content-Type', 'X-Response-Time'],
  maxAge: 86400 // 24 hours cache for preflight requests
}));

// Debug middleware to see what's coming in (before body parsing)
app.use((req, res, next) => {
  console.log(`🔍 Request: ${req.method} ${req.path}`);
  console.log(`🔍 Content-Type: ${req.headers['content-type']}`);
  console.log(`🔍 Content-Length: ${req.headers['content-length']}`);
  console.log(`🔍 User-Agent: ${req.headers['user-agent']}`);
  next();
});

// Enhanced JSON parsing with mobile device support
app.use(express.json({ 
  limit: '100mb',
  type: 'application/json' // Only parse application/json, not text/plain
}));

app.use(express.urlencoded({ 
  limit: '100mb', 
  extended: true
}));

// Mobile-specific headers
app.use((req, res, next) => {
  // Add mobile-friendly headers
  res.header('X-Content-Type-Options', 'nosniff');
  res.header('X-Frame-Options', 'SAMEORIGIN');
  res.header('X-XSS-Protection', '1; mode=block');
  res.header('Cache-Control', 'no-cache, no-store, must-revalidate');
  res.header('Pragma', 'no-cache');
  res.header('Expires', '0');
  
  // Mobile device detection
  const userAgent = req.headers['user-agent'] || '';
  const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(userAgent);
  
  if (isMobile) {
    console.log(`📱 Mobile device detected: ${userAgent}`);
    // Add mobile-specific optimizations
    res.header('X-Mobile-Optimized', 'true');
  }
  
  next();
});

// Конфигурация прокси из переменных окружения
// FIXED: Правильное чтение переменных (игнорируем пустые строки)
const getProxyList = () => {
  const allProxy = (process.env.ALL_PROXY || '').trim();
  
  // Используем ТОЛЬКО ALL_PROXY, никаких fallback на HTTP_PROXY или прямые запросы
  if (allProxy.length > 0) {
    console.log('🔧 Using ALL_PROXY');
    // Разбираем список прокси (может быть несколько через запятую)
    const proxyUrls = allProxy.split(',').map(s => s.trim()).filter(s => s.length > 0);
    return proxyUrls;
  } else {
    console.log('❌ ALL_PROXY is empty - NO PROXY CONFIGURED');
    return []; // Возвращаем пустой массив, НЕ [null]
  }
};

const PROXY_URLS = getProxyList();

console.log('🔧 Proxy Server Configuration:');
console.log('   Proxies:', PROXY_URLS.length);

// Создаем агенты для прокси
let currentProxyIndex = 0;

// Build proxy URL candidates from various formats.
// - If full URL provided, use as-is
// - If in host:port:user:pass form, convert to socks5h
function buildProxyUrlCandidates(proxyStr) {
  const trimmed = (proxyStr || '').trim();
  
  // Если URL уже с протоколом - использовать как есть
  if (trimmed.includes('://')) {
    return [trimmed];
  }

  // Если формат host:port:user:pass - конвертировать в socks5h
  const parts = trimmed.split(':');
  if (parts.length === 4) {
    const [host, port, username, password] = parts;
    return [`socks5h://${username}:${password}@${host}:${port}`];
  }

  // Если формат host:port - использовать без аутентификации
  if (parts.length === 2) {
    const [host, port] = parts;
    return [`socks5h://${host}:${port}`];
  }

  return [trimmed];
}

// Try node-fetch through proxies with parallel fast failover (Promise.any)
async function fetchThroughProxies(targetUrl, baseOptions) {
  const proxies = PROXY_URLS; // Используем ТОЛЬКО прокси из ALL_PROXY, никаких fallback

  let lastError = null;
  const perProxyTimeoutMs = 15000; // 15s per proxy
  const attempts = proxies.map((proxy) => {
    return new Promise(async (resolve, reject) => {
      const timeoutId = setTimeout(() => {
        reject(new Error('proxy_timeout'));
      }, perProxyTimeoutMs);

      try {
        let agent = null;
        const proxyUrl = proxy; // Всегда есть прокси, никаких null
        
        console.log(`🌐 Trying proxy: ${proxyUrl.replace(/:[^:@]+@/, ':****@')}`);
        
        if (proxyUrl.startsWith('socks5h://') || proxyUrl.startsWith('socks5://')) {
          agent = new SocksProxyAgent(proxyUrl);
        } else if (proxyUrl.startsWith('http://') || proxyUrl.startsWith('https://')) {
          agent = new HttpsProxyAgent(proxyUrl);
        }

        const fetchOptions = {
          method: baseOptions.method || 'POST',
          headers: baseOptions.headers || {},
          body: baseOptions.body || JSON.stringify(baseOptions.data),
          timeout: perProxyTimeoutMs,
          agent: agent,
        };

        const response = await fetch(targetUrl, fetchOptions);
        clearTimeout(timeoutId);
        
        console.log(`✅ Proxy OK: ${proxyUrl.replace(/:[^:@]+@/, ':****@')}`);
        
        resolve(response);
      } catch (error) {
        clearTimeout(timeoutId);
        lastError = error;
        console.error(`❌ Request via ${proxy} failed: ${error.message}`);
        reject(error);
      }
    });
  });

  try {
    return Promise.any(attempts);
  } catch (e) {
    throw lastError || e || new Error('All proxies failed');
  }
}

// (Legacy helper no longer needed with parallel attempts)

function getCurrentProxyAgent() {
  if (PROXY_URLS.length === 0) {
    return null; // No proxy configured
  }
  return null;
}

// Temporary function to test without proxy
function getTestProxyAgent() {
  console.log('🧪 Testing without HTTP proxy...');
  return null; // No proxy for testing
}

function switchToNextProxy() {
  if (PROXY_URLS.length > 1) {
    currentProxyIndex = (currentProxyIndex + 1) % PROXY_URLS.length;
    const nextProxy = PROXY_URLS[currentProxyIndex];
    console.log(`🔄 Switching to backup proxy: ${nextProxy}`);
    const url = buildProxyUrlCandidates(nextProxy)[0];
    return new AnyProxyAgent(url);
  }
  return null;
}

// Маршрут для проксирования запросов к OpenAI
app.post('/openai/*', async (req, res) => {
  try {
    console.log(`🚀 Received OpenAI request: ${req.path}`);
    console.log(`📤 Request method: ${req.method}`);
    console.log(`📤 Request headers:`, req.headers);
    console.log(`📤 Request body type:`, typeof req.body);
    console.log(`📤 Request body:`, req.body);
    console.log(`📤 Raw body length:`, req.body ? JSON.stringify(req.body).length : 'undefined');
    
    const targetUrl = 'https://api.openai.com' + req.path.replace('/openai', '');
    
    console.log(`🚀 Proxying OpenAI request to: ${targetUrl}`);
    
    // Enhanced headers for mobile compatibility
    const headers = {
      'Content-Type': 'application/json',
      'Authorization': req.headers.authorization,
      'User-Agent': 'LandComp-AI-Client/1.0',
      'Accept': 'application/json, text/plain, */*',
      'Accept-Language': req.headers['accept-language'] || 'en-US,en;q=0.9',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
    };

    // Add mobile-specific headers if detected
    const userAgent = req.headers['user-agent'] || '';
    const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(userAgent);
    
    if (isMobile) {
      headers['X-Mobile-Client'] = 'true';
      headers['X-Requested-With'] = 'XMLHttpRequest';
    }

    const fetchOptions = {
      method: req.method,
      headers: headers,
      body: JSON.stringify(req.body),
      timeout: 300000, // 5 minutes total upper bound (per-proxy is shorter)
      compress: true, // Enable compression for mobile
    };
    
    const response = await fetchThroughProxies(targetUrl, fetchOptions);

    const data = await response.text();
    
    // Проверяем, является ли ответ JSON
    try {
      const jsonData = JSON.parse(data);
      res.status(response.status).json(jsonData);
    } catch (e) {
      res.status(response.status).send(data);
    }
    
  } catch (error) {
    console.error('❌ OpenAI proxy error:', error.message);
    
    // Быстрый отказ уже выполнен в fetchThroughProxies
    res.status(500).json({ 
      error: 'Proxy request failed', 
      details: error.message 
    });
  }
});

// Маршрут для проксирования запросов к Google Gemini
app.post('/gemini/*', async (req, res) => {
  try {
    // Строим полный URL с query параметрами
    const pathWithoutProxy = req.path.replace('/gemini', '');
    const queryString = req.url.includes('?') ? req.url.substring(req.url.indexOf('?')) : '';
    const targetUrl = 'https://generativelanguage.googleapis.com' + pathWithoutProxy + queryString;
    
    console.log(`🚀 Proxying Gemini request to: ${targetUrl}`);
    console.log(`🔍 Original path: ${req.path}`);
    console.log(`🔍 Query params: ${req.query}`);
    console.log(`🔍 Full URL: ${req.url}`);
    
    // Прокси агент создается внутри fast-failover функции

    // Извлекаем API ключ из URL
    const url = new URL(targetUrl);
    const apiKey = url.searchParams.get('key');
    
    // Enhanced headers for mobile compatibility
    const headers = {
      'Content-Type': 'application/json',
      'User-Agent': 'LandComp-AI-Client/1.0',
      'Accept': 'application/json, text/plain, */*',
      'Accept-Language': req.headers['accept-language'] || 'en-US,en;q=0.9',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
    };
    
    // Add mobile-specific headers if detected
    const userAgent = req.headers['user-agent'] || '';
    const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(userAgent);
    
    if (isMobile) {
      headers['X-Mobile-Client'] = 'true';
      headers['X-Requested-With'] = 'XMLHttpRequest';
    }
    
    // Добавляем API ключ в заголовки
    if (apiKey) {
      headers['x-goog-api-key'] = apiKey;
      console.log(`🔑 API Key found: ${apiKey.substring(0, 10)}...`);
    } else {
      console.log('⚠️ No API key found in URL');
      console.log(`🔍 Full URL: ${targetUrl}`);
    }
    
    // Убираем API ключ из URL для безопасности
    // Сохраняем key и в query, и в заголовке для совместимости
    const cleanTargetUrl = url.toString();

    const fetchOptions = {
      method: req.method,
      headers: headers,
      body: JSON.stringify(req.body),
      timeout: 300000, // 5 minutes total upper bound (per-proxy is shorter)
      compress: true, // Enable compression for mobile
    };
    
    const response = await fetchThroughProxies(cleanTargetUrl, fetchOptions);

    const data = await response.text();
    
    res.status(response.status).json(JSON.parse(data));
    
  } catch (error) {
    console.error('❌ Gemini proxy error:', error.message);
    
    // Быстрый отказ уже выполнен в fetchThroughProxies
    res.status(500).json({ 
      error: 'Proxy request failed', 
      details: error.message 
    });
  }
});

// Маршрут для проверки статуса прокси
app.get('/status', (req, res) => {
  res.json({
    status: 'running',
    mainProxy: PROXY_URLS[0] || null,
    backupProxies: Math.max(0, PROXY_URLS.length - 1),
    currentProxyIndex: currentProxyIndex,
  });
});

// Test route for debugging
app.post('/test', (req, res) => {
  console.log('🚀 Test route hit!');
  console.log('📤 Request body:', req.body);
  res.json({ message: 'Test route working', body: req.body });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    proxy: 'running'
  });
});

// Mobile diagnostics endpoint
app.get('/mobile-diagnostics', (req, res) => {
  const userAgent = req.headers['user-agent'] || '';
  const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(userAgent);
  
  res.json({
    timestamp: new Date().toISOString(),
    device: {
      isMobile,
      userAgent,
      platform: req.headers['sec-ch-ua-platform'] || 'unknown',
      language: req.headers['accept-language'] || 'unknown'
    },
    proxy: {
      status: 'running',
      mainProxy: PROXY_URLS[0] || null,
      backupProxies: Math.max(0, PROXY_URLS.length - 1),
      currentProxyIndex: currentProxyIndex
    },
    capabilities: {
      cors: true,
      compression: true,
      mobileOptimized: true,
      extendedTimeout: isMobile
    }
  });
});

// Запуск сервера
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Proxy server running on http://0.0.0.0:${PORT}`);
  console.log(`📡 Ready to proxy requests through: ${PROXY_URLS[0] || 'direct'}`);
});

// Обработка ошибок
process.on('uncaughtException', (error) => {
  console.error('❌ Uncaught Exception:', error);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Unhandled Rejection at:', promise, 'reason:', reason);
});
