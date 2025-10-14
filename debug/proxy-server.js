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

// Middleware
app.use(cors());
app.use(express.json({ limit: '100mb' })); // Увеличиваем лимит для больших изображений
app.use(express.urlencoded({ limit: '100mb', extended: true }));

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

    const response = await fetch(targetUrl, {
      method: req.method,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': req.headers.authorization,
        'User-Agent': 'LandComp-AI-Client/1.0',
      },
      body: JSON.stringify(req.body),
      agent: agent,
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
    
    const headers = {
      'Content-Type': 'application/json',
      'User-Agent': 'LandComp-AI-Client/1.0',
    };
    
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
      timeout: 120000, // 2 minutes for large images
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
