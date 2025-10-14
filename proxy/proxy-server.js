/// Простой прокси-сервер для веб-версии Flutter приложения
/// 
/// Этот сервер принимает запросы от веб-приложения и проксирует их
/// через указанный SOCKS5 прокси к API сервисам.

const express = require('express');
const { SocksProxyAgent } = require('socks-proxy-agent');
const fetch = require('node-fetch');
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

// Enhanced JSON parsing with mobile device support
app.use(express.json({ 
  limit: '100mb',
  type: ['application/json', 'text/plain', 'application/x-www-form-urlencoded']
}));

app.use(express.urlencoded({ 
  limit: '100mb', 
  extended: true,
  type: ['application/x-www-form-urlencoded', 'multipart/form-data']
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
const PROXY_URL = process.env.ALL_PROXY || 'socks5h://xexEUhKx:AXySXT2c@45.192.51.104:63435';
const BACKUP_PROXIES = (process.env.BACKUP_PROXIES || '').split(',').filter(p => p.trim());

console.log('🔧 Proxy Server Configuration:');
console.log('   Main Proxy:', PROXY_URL);
console.log('   Backup Proxies:', BACKUP_PROXIES.length);

// Создаем агент для прокси
let currentProxyAgent = null;
let currentProxyIndex = 0;

function createProxyAgent(proxyUrl) {
  try {
    return new SocksProxyAgent(proxyUrl);
  } catch (error) {
    console.error('❌ Error creating proxy agent:', error.message);
    return null;
  }
}

function getCurrentProxyAgent() {
  if (!currentProxyAgent) {
    currentProxyAgent = createProxyAgent(PROXY_URL);
  }
  return currentProxyAgent;
}

function switchToNextProxy() {
  if (BACKUP_PROXIES.length > 0) {
    currentProxyIndex = (currentProxyIndex + 1) % BACKUP_PROXIES.length;
    const nextProxy = BACKUP_PROXIES[currentProxyIndex];
    console.log(`🔄 Switching to backup proxy: ${nextProxy}`);
    currentProxyAgent = createProxyAgent(nextProxy);
    return currentProxyAgent;
  }
  return null;
}

// Маршрут для проксирования запросов к OpenAI
app.post('/proxy/openai/*', async (req, res) => {
  try {
    const targetUrl = 'https://api.openai.com' + req.path.replace('/proxy/openai', '');
    
    console.log(`🚀 Proxying OpenAI request to: ${targetUrl}`);
    console.log(`📤 Request body:`, JSON.stringify(req.body, null, 2));
    console.log(`📤 Request headers:`, req.headers);
    
    const agent = getCurrentProxyAgent();
    if (!agent) {
      return res.status(500).json({ error: 'Proxy agent not available' });
    }

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

    const response = await fetch(targetUrl, {
      method: req.method,
      headers: headers,
      body: JSON.stringify(req.body),
      agent: agent,
      timeout: isMobile ? 180000 : 120000, // Longer timeout for mobile devices
      compress: true, // Enable compression for mobile
    });

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
    
    // Попробуем переключиться на резервный прокси
    const backupAgent = switchToNextProxy();
    if (backupAgent) {
      try {
        const targetUrl = 'https://api.openai.com' + req.path.replace('/proxy/openai', '');
        const response = await fetch(targetUrl, {
          method: req.method,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': req.headers.authorization,
            'User-Agent': 'LandComp-AI-Client/1.0',
          },
          body: JSON.stringify(req.body),
          agent: backupAgent,
          timeout: 120000, // 2 minutes for large images
        });

        const data = await response.text();
        
        // Проверяем, является ли ответ JSON
        try {
          const jsonData = JSON.parse(data);
          res.status(response.status).json(jsonData);
        } catch (e) {
          res.status(response.status).send(data);
        }
        return;
      } catch (backupError) {
        console.error('❌ Backup proxy also failed:', backupError.message);
      }
    }
    
    res.status(500).json({ 
      error: 'Proxy request failed', 
      details: error.message 
    });
  }
});

// Маршрут для проксирования запросов к Google Gemini
app.post('/proxy/gemini/*', async (req, res) => {
  try {
    // Строим полный URL с query параметрами
    const pathWithoutProxy = req.path.replace('/proxy/gemini', '');
    const queryString = req.url.includes('?') ? req.url.substring(req.url.indexOf('?')) : '';
    const targetUrl = 'https://generativelanguage.googleapis.com' + pathWithoutProxy + queryString;
    
    console.log(`🚀 Proxying Gemini request to: ${targetUrl}`);
    console.log(`🔍 Original path: ${req.path}`);
    console.log(`🔍 Query params: ${req.query}`);
    console.log(`🔍 Full URL: ${req.url}`);
    
    const agent = getCurrentProxyAgent();
    if (!agent) {
      return res.status(500).json({ error: 'Proxy agent not available' });
    }

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
    url.searchParams.delete('key');
    const cleanTargetUrl = url.toString();

    const response = await fetch(cleanTargetUrl, {
      method: req.method,
      headers: headers,
      body: JSON.stringify(req.body),
      agent: agent,
      timeout: isMobile ? 180000 : 120000, // Longer timeout for mobile devices
      compress: true, // Enable compression for mobile
    });

    const data = await response.text();
    
    res.status(response.status).json(JSON.parse(data));
    
  } catch (error) {
    console.error('❌ Gemini proxy error:', error.message);
    
    // Попробуем переключиться на резервный прокси
    const backupAgent = switchToNextProxy();
    if (backupAgent) {
      try {
        const targetUrl = 'https://generativelanguage.googleapis.com' + req.path.replace('/proxy/gemini', '');
        const url = new URL(targetUrl);
        const apiKey = url.searchParams.get('key');
        
        const headers = {
          'Content-Type': 'application/json',
          'User-Agent': 'LandComp-AI-Client/1.0',
        };
        
        if (apiKey) {
          headers['x-goog-api-key'] = apiKey;
        }
        
        url.searchParams.delete('key');
        const cleanTargetUrl = url.toString();
        
        const response = await fetch(cleanTargetUrl, {
          method: req.method,
          headers: headers,
          body: JSON.stringify(req.body),
          agent: backupAgent,
          timeout: 120000, // 2 minutes for large images
        });

        const data = await response.text();
        
        // Проверяем, является ли ответ JSON
        try {
          const jsonData = JSON.parse(data);
          res.status(response.status).json(jsonData);
        } catch (e) {
          res.status(response.status).send(data);
        }
        return;
      } catch (backupError) {
        console.error('❌ Backup proxy also failed:', backupError.message);
      }
    }
    
    res.status(500).json({ 
      error: 'Proxy request failed', 
      details: error.message 
    });
  }
});

// Маршрут для проверки статуса прокси
app.get('/proxy/status', (req, res) => {
  res.json({
    status: 'running',
    mainProxy: PROXY_URL,
    backupProxies: BACKUP_PROXIES.length,
    currentProxyIndex: currentProxyIndex,
  });
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
      mainProxy: PROXY_URL,
      backupProxies: BACKUP_PROXIES.length,
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
app.listen(PORT, () => {
  console.log(`🚀 Proxy server running on http://localhost:${PORT}`);
  console.log(`📡 Ready to proxy requests through: ${PROXY_URL}`);
});

// Обработка ошибок
process.on('uncaughtException', (error) => {
  console.error('❌ Uncaught Exception:', error);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Unhandled Rejection at:', promise, 'reason:', reason);
});
