# Анализ системы прокси: выявленные ошибки и решения

**Дата:** 2025-10-15  
**Статус:** Критические ошибки обнаружены

## Оглавление
1. [Архитектура текущей системы](#архитектура-текущей-системы)
2. [Критические ошибки](#критические-ошибки)
3. [Архитектурные проблемы](#архитектурные-проблемы)
4. [Рекомендуемые решения](#рекомендуемые-решения)

---

## Архитектура текущей системы

### Текущий поток данных:

```
[Flutter Web App] 
    ↓ HTTP Request: /proxy/openai/...
[Nginx в Docker] 
    ↓ proxy_pass на landcomp-proxy:3001/
[Proxy Server (Node.js)]
    ↓ Через SOCKS5 прокси
[External AI API]
```

### Компоненты:
1. **Flutter приложение** (web/native)
2. **Nginx** - reverse proxy
3. **Proxy Server** - Node.js сервер (Express + undici + proxy-agent)
4. **Docker Compose** - оркестрация
5. **SOCKS5 прокси** - внешний сервер

---

## Критические ошибки

### ❌ ОШИБКА 1: Отсутствие healthcheck в прокси-сервере

**Проблема:**
- `docker-compose.prod.yml:69` требует `condition: service_healthy`
- `Dockerfile.proxy` НЕ содержит HEALTHCHECK
- Контейнер `landcomp-app` не сможет запуститься

**Локация:**
- `Dockerfile.proxy` - отсутствует HEALTHCHECK
- `docker-compose.prod.yml:68-69` - зависимость с condition

**Последствия:**
```
ERROR: for landcomp-app  Container is unhealthy
```

**Решение:**
Добавить HEALTHCHECK в `Dockerfile.proxy`:
```dockerfile
HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3001/health', (res) => process.exit(res.statusCode === 200 ? 0 : 1))"
```

---

### ❌ ОШИБКА 2: Переменные окружения не попадают в Flutter Web

**Проблема:**
- `Dockerfile:45-59` генерирует `.env` файл в runtime (после компиляции)
- Flutter Web компилируется статически во время build
- Скомпилированный JS не может читать `.env` файл, созданный после build

**Локация:**
- `Dockerfile:30` - `flutter build web --release`
- `Dockerfile:45-59` - генерация `.env` выполняется ПОСЛЕ сборки
- `lib/core/config/env_config.dart:19-21` - web пытается читать dotenv

**Последствия:**
- Flutter Web не имеет доступа к API ключам
- Прокси конфигурация недоступна
- Все запросы будут падать с ошибкой "API key not configured"

**Текущий flow:**
```
1. flutter build web          → создает статический JS
2. Nginx запускается          → выполняется generate-env.sh
3. Создается .env файл        → НО JS уже скомпилирован!
4. Flutter загружает .env     → .env существует, но переменные пустые
```

**Решение (3 варианта):**

#### Вариант A: Build-time переменные (РЕКОМЕНДУЕТСЯ)
```dockerfile
# Передать переменные во время сборки
ARG OPENAI_API_KEY
ARG GOOGLE_API_KEY
RUN echo "OPENAI_API_KEY=$OPENAI_API_KEY" > .env && \
    flutter build web --release --dart-define=ENV_MODE=production
```

#### Вариант B: JavaScript injection
Создать `env.js` с переменными и внедрить через `index.html`:
```html
<script src="env.js"></script>
<script src="main.dart.js"></script>
```

#### Вариант C: API endpoint
Создать `/config` endpoint в proxy-server, который возвращает конфигурацию.

---

### ❌ ОШИБКА 3: Конфликт приоритета прокси-переменных

**Проблема:**
- `proxy-server.js:68` - `const RAW_PROXY_LIST = process.env.HTTP_PROXY || process.env.ALL_PROXY`
- `env.example:12` - `HTTP_PROXY=` (пустая строка)
- Пустая строка имеет приоритет над `ALL_PROXY`, но по логике должна игнорироваться

**Локация:**
- `proxy/proxy-server.js:68`

**Последствия:**
- Если `HTTP_PROXY` установлен как пустая строка, прокси не будет использоваться
- `ALL_PROXY` будет проигнорирован

**Решение:**
```javascript
const RAW_PROXY_LIST = process.env.HTTP_PROXY?.trim() || 
                       process.env.ALL_PROXY?.trim() || '';
```

Или явно проверять:
```javascript
const getProxyList = () => {
  const httpProxy = process.env.HTTP_PROXY?.trim();
  const allProxy = process.env.ALL_PROXY?.trim();
  
  if (httpProxy && httpProxy.length > 0) return httpProxy;
  if (allProxy && allProxy.length > 0) return allProxy;
  return '';
};
```

---

### ❌ ОШИБКА 4: Несоответствие путей в Docker Compose

**Проблема:**
- `docker-compose.yml:8` - `dockerfile: Dockerfile.proxy`
- `docker-compose.prod.yml:8` - `dockerfile: Dockerfile`
- Но контекст - `./proxy`, а файл `Dockerfile` находится в корне!

**Локация:**
- `docker-compose.prod.yml:7-8`

**Последствия:**
```
ERROR: Cannot locate specified Dockerfile: Dockerfile
```

**Решение:**
Исправить `docker-compose.prod.yml:7-8`:
```yaml
landcomp-proxy:
  build:
    context: ./proxy
    dockerfile: Dockerfile  # ← Должен быть Dockerfile внутри ./proxy
```

**Варианты:**
1. Переименовать `Dockerfile.proxy` → `proxy/Dockerfile`
2. Изменить путь в prod: `dockerfile: ../Dockerfile.proxy`

---

### ❌ ОШИБКА 5: Неиспользуемые заголовки X-Proxy-*

**Проблема:**
- `ai_service.dart:183-194` - устанавливает заголовки `X-Proxy-Host`, `X-Proxy-Port`, `X-Proxy-User`, `X-Proxy-Pass`
- `proxy-server.js` - НЕ читает эти заголовки!
- Прокси берется только из переменных окружения `HTTP_PROXY`/`ALL_PROXY`

**Локация:**
- `lib/core/network/ai_service.dart:183-194`
- `proxy/proxy-server.js:68` - не использует заголовки

**Последствия:**
- Динамическая настройка прокси невозможна
- Заголовки передаются впустую
- Увеличение размера запроса

**Решение:**
Либо удалить установку заголовков в Flutter, либо реализовать их чтение в proxy-server:

```javascript
app.post('/openai/*', async (req, res) => {
  // Читаем прокси из заголовков, если передан
  const proxyHost = req.headers['x-proxy-host'];
  const proxyPort = req.headers['x-proxy-port'];
  const proxyUser = req.headers['x-proxy-user'];
  const proxyPass = req.headers['x-proxy-pass'];
  
  let dynamicProxy = null;
  if (proxyHost && proxyPort) {
    const auth = proxyUser && proxyPass ? `${proxyUser}:${proxyPass}@` : '';
    dynamicProxy = `socks5h://${auth}${proxyHost}:${proxyPort}`;
  }
  
  // Использовать динамический прокси или default
  const proxyToUse = dynamicProxy || PROXY_URLS[0];
  // ...
});
```

---

## Архитектурные проблемы

### ⚠️ ПРОБЛЕМА 1: SOCKS5 прокси внутри Docker

**Проблема:**
- Прокси-сервер работает в Docker-контейнере
- SOCKS5 прокси указан как внешний хост (например, `111111111111114:3333333333`)
- Docker-контейнер может не иметь доступа к этому хосту

**Сценарии:**
1. **Если прокси на том же сервере:**
   - Нужно использовать `host.docker.internal` или IP хоста
   - Или режим `network_mode: host` в docker-compose

2. **Если прокси внешний:**
   - Убедиться что Docker может резолвить DNS
   - Проверить доступность порта из контейнера

**Решение:**
Добавить в `docker-compose.prod.yml`:
```yaml
landcomp-proxy:
  # Если прокси на локальном хосте:
  extra_hosts:
    - "proxy-host:host-gateway"
  
  # Или использовать host network mode (менее безопасно):
  # network_mode: host
```

И изменить `.env`:
```bash
# Использовать host-gateway вместо прямого IP
ALL_PROXY=socks5h://user:pass@proxy-host:port
```

---

### ⚠️ ПРОБЛЕМА 2: Native приложения не могут подключиться к прокси-серверу

**Проблема:**
- `ai_service.dart:173` - hardcoded IP: `89.111.171.89:3001`
- Мобильные устройства могут не иметь доступа к этому IP
- Нет fallback механизма для native платформ

**Локация:**
- `lib/core/network/ai_service.dart:164-180`

**Сценарии проблем:**
1. Мобильное устройство в другой сети
2. Firewall блокирует порт 3001
3. Сервер недоступен

**Решение:**

#### Вариант A: Публичный домен
```dart
String proxyServerUrl;
if (serverHost.isNotEmpty) {
  proxyServerUrl = 'https://$serverHost/proxy';  // Через nginx на 80/443
} else {
  proxyServerUrl = 'https://landcomp.example.com/proxy';
}
```

#### Вариант B: Direct connection без прокси-сервера
```dart
if (kIsWeb) {
  // Web: через proxy-server
  _dio.options.baseUrl = '';
} else {
  // Native: прямое подключение к AI API
  _dio.options.baseUrl = 'https://api.openai.com';
  // Настроить SOCKS5 прокси через HttpClient
}
```

---

### ⚠️ ПРОБЛЕМА 3: Избыточная сложность архитектуры

**Текущая архитектура:**
```
Flutter Web → Nginx → Proxy Server → SOCKS5 → AI API
```

**Проблемы:**
1. Много точек отказа
2. Сложная отладка
3. Увеличенная латентность (3 прокси-прыжка)
4. Proxy-server фактически просто форвардит запросы

**Альтернативы:**

#### Вариант A: Nginx напрямую с SOCKS5
Использовать модуль `ngx_stream_proxy_module`:
```nginx
stream {
    upstream ai_backend {
        server api.openai.com:443;
    }
    
    server {
        listen 3001;
        proxy_pass ai_backend;
        proxy_connect_timeout 30s;
    }
}
```

#### Вариант B: Убрать proxy-server для Web
Flutter Web работает через CORS proxy, но для production:
```
Flutter Web → Nginx → SOCKS5 → AI API
```

#### Вариант C: Cloudflare Workers (РЕКОМЕНДУЕТСЯ)
Развернуть Cloudflare Worker как прокси:
```javascript
// worker.js
export default {
  async fetch(request) {
    const url = new URL(request.url);
    const targetUrl = 'https://api.openai.com' + url.pathname;
    
    const response = await fetch(targetUrl, {
      method: request.method,
      headers: request.headers,
      body: request.body
    });
    
    return response;
  }
}
```

**Преимущества:**
- Глобальный CDN
- Автоматическое масштабирование
- Встроенный SSL
- Нет необходимости в SOCKS5
- Работает для web и native

---

### ⚠️ ПРОБЛЕМА 4: Отсутствие логирования и мониторинга

**Проблемы:**
1. Нет централизованного логирования
2. Нет метрик производительности
3. Сложно отследить проблемы с прокси

**Решение:**
Добавить в proxy-server:

```javascript
const morgan = require('morgan');
const fs = require('fs');

// Логирование в файл
const accessLogStream = fs.createWriteStream(
  '/var/log/proxy/access.log', 
  { flags: 'a' }
);

app.use(morgan('combined', { stream: accessLogStream }));

// Метрики
let requestCount = 0;
let errorCount = 0;
let totalResponseTime = 0;

app.use((req, res, next) => {
  const start = Date.now();
  requestCount++;
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    totalResponseTime += duration;
    
    if (res.statusCode >= 400) errorCount++;
  });
  
  next();
});

// Endpoint метрик
app.get('/metrics', (req, res) => {
  res.json({
    requests: requestCount,
    errors: errorCount,
    avgResponseTime: totalResponseTime / requestCount,
    uptime: process.uptime()
  });
});
```

---

## Рекомендуемые решения

### 🎯 Решение 1: Исправить критические ошибки (НЕМЕДЛЕННО)

**Приоритет: КРИТИЧЕСКИЙ**

1. **Добавить healthcheck в Dockerfile.proxy:**
```dockerfile
# В конец Dockerfile.proxy
HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3001/health', (res) => process.exit(res.statusCode === 200 ? 0 : 1))"
```

2. **Исправить чтение прокси-переменных:**
```javascript
// proxy/proxy-server.js:68
const RAW_PROXY_LIST = (process.env.HTTP_PROXY || process.env.ALL_PROXY || '').trim();
const PROXY_URLS = RAW_PROXY_LIST.split(',').map(s => s.trim()).filter(Boolean);
```

3. **Исправить Dockerfile prod:**
```yaml
# docker-compose.prod.yml
landcomp-proxy:
  build:
    context: ./proxy
    dockerfile: Dockerfile  # Переименовать Dockerfile.proxy → proxy/Dockerfile
```

4. **Исправить переменные окружения для Flutter Web:**

Вариант с env.js (проще всего):

`Dockerfile`:
```dockerfile
# После строки 59, перед CMD
RUN echo '#!/bin/sh' > /usr/local/bin/generate-config.sh && \
    echo 'cat > /usr/share/nginx/html/env.js <<EOF' >> /usr/local/bin/generate-config.sh && \
    echo 'window.ENV = {' >> /usr/local/bin/generate-config.sh && \
    echo '  OPENAI_API_KEY: "${OPENAI_API_KEY}",' >> /usr/local/bin/generate-config.sh && \
    echo '  GOOGLE_API_KEY: "${GOOGLE_API_KEY}",' >> /usr/local/bin/generate-config.sh && \
    echo '  ALL_PROXY: "${ALL_PROXY}"' >> /usr/local/bin/generate-config.sh && \
    echo '};' >> /usr/local/bin/generate-config.sh && \
    echo 'EOF' >> /usr/local/bin/generate-config.sh && \
    chmod +x /usr/local/bin/generate-config.sh

CMD ["sh", "-c", "/usr/local/bin/generate-config.sh && nginx -g 'daemon off;'"]
```

`web/index.html`:
```html
<!-- После <script src="flutter_bootstrap.js" async></script> -->
<script src="env.js"></script>
```

`lib/core/config/env_config.dart`:
```dart
import 'dart:js' as js;

static String _getEnvVar(String key) {
  if (kIsWeb) {
    try {
      final env = js.context['ENV'];
      if (env != null) {
        final value = env[key];
        return value?.toString() ?? '';
      }
    } catch (e) {
      debugPrint('Error reading env from window.ENV: $e');
    }
    return '';
  }
  // ... existing code for native
}
```

---

### 🎯 Решение 2: Упростить архитектуру (РЕКОМЕНДУЕТСЯ)

**Приоритет: ВЫСОКИЙ**

**Новая архитектура:**

```
┌─────────────────┐
│  Flutter App    │
│  (Web/Native)   │
└────────┬────────┘
         │
         ├─── Web: через Nginx reverse proxy
         └─── Native: прямо к Cloudflare Worker
                      │
         ┌────────────▼───────────┐
         │  Cloudflare Worker     │
         │  (Глобальный прокси)   │
         └────────────┬───────────┘
                      │
         ┌────────────▼───────────┐
         │   AI APIs              │
         │   (OpenAI, Gemini)     │
         └────────────────────────┘
```

**Преимущества:**
- Убираем SOCKS5 прокси
- Убираем Node.js proxy-server
- Единая точка входа
- Глобальный CDN
- Автоматическое масштабирование
- Встроенная защита от DDoS
- Простая отладка

**Реализация:**

1. **Создать Cloudflare Worker:**

```javascript
// cloudflare-worker.js
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    
    // Определяем целевой API
    let targetBase;
    if (url.pathname.startsWith('/openai/')) {
      targetBase = 'https://api.openai.com';
      url.pathname = url.pathname.replace('/openai', '');
    } else if (url.pathname.startsWith('/gemini/')) {
      targetBase = 'https://generativelanguage.googleapis.com';
      url.pathname = url.pathname.replace('/gemini', '');
    } else {
      return new Response('Invalid endpoint', { status: 404 });
    }
    
    const targetUrl = targetBase + url.pathname + url.search;
    
    // Копируем headers
    const headers = new Headers(request.headers);
    headers.set('User-Agent', 'LandComp-AI-Client/1.0');
    
    // Форвардим запрос
    const response = await fetch(targetUrl, {
      method: request.method,
      headers: headers,
      body: request.body
    });
    
    // Добавляем CORS headers
    const newResponse = new Response(response.body, response);
    newResponse.headers.set('Access-Control-Allow-Origin', '*');
    newResponse.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    newResponse.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    
    return newResponse;
  }
};
```

2. **Настроить routes в Cloudflare:**
```
landcomp.example.com/api/* → cloudflare-worker
```

3. **Изменить Flutter код:**

```dart
// lib/core/network/ai_service.dart

void _configureWebProxy(Uri proxyUri) {
  if (kIsWeb) {
    // Для web используем относительные URL через nginx
    _dio.options.baseUrl = '';
  } else {
    // Для native используем Cloudflare Worker
    _dio.options.baseUrl = 'https://landcomp.example.com/api';
  }
}

Future<String> sendToOpenAI({...}) async {
  final url = kIsWeb
      ? '/proxy/openai/v1/chat/completions'
      : '/openai/v1/chat/completions';  // Через Cloudflare
  // ...
}
```

4. **Обновить docker-compose:**

```yaml
# Убираем landcomp-proxy сервис
# Оставляем только landcomp-app

services:
  landcomp-app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "80:80"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - GOOGLE_API_KEY=${GOOGLE_API_KEY}
```

5. **Обновить nginx.conf:**

```nginx
# Для web версии проксируем на Cloudflare Worker
location /proxy/ {
    proxy_pass https://landcomp.example.com/api/;
    proxy_ssl_server_name on;
    proxy_set_header Host landcomp.example.com;
    # ... остальные настройки
}
```

---

### 🎯 Решение 3: Оставить текущую архитектуру, но улучшить

**Приоритет: СРЕДНИЙ**

Если нужно сохранить SOCKS5 прокси:

**Изменения:**

1. **Добавить поддержку нескольких прокси стратегий:**

```javascript
// proxy/proxy-server.js

const PROXY_STRATEGY = process.env.PROXY_STRATEGY || 'failover'; // 'failover' | 'round-robin' | 'fastest'

class ProxyManager {
  constructor(proxyUrls) {
    this.proxies = proxyUrls.map(url => ({
      url,
      failures: 0,
      lastUsed: 0,
      avgResponseTime: 0
    }));
    this.currentIndex = 0;
  }
  
  getNextProxy() {
    switch (PROXY_STRATEGY) {
      case 'round-robin':
        return this.getRoundRobin();
      case 'fastest':
        return this.getFastest();
      default:
        return this.getFailover();
    }
  }
  
  getRoundRobin() {
    const proxy = this.proxies[this.currentIndex];
    this.currentIndex = (this.currentIndex + 1) % this.proxies.length;
    return proxy;
  }
  
  getFastest() {
    return this.proxies.reduce((fastest, current) => 
      current.avgResponseTime < fastest.avgResponseTime ? current : fastest
    );
  }
  
  getFailover() {
    return this.proxies.find(p => p.failures < 3) || this.proxies[0];
  }
  
  recordSuccess(proxyUrl, responseTime) {
    const proxy = this.proxies.find(p => p.url === proxyUrl);
    if (proxy) {
      proxy.failures = Math.max(0, proxy.failures - 1);
      proxy.avgResponseTime = (proxy.avgResponseTime * 0.8 + responseTime * 0.2);
      proxy.lastUsed = Date.now();
    }
  }
  
  recordFailure(proxyUrl) {
    const proxy = this.proxies.find(p => p.url === proxyUrl);
    if (proxy) {
      proxy.failures++;
    }
  }
}

const proxyManager = new ProxyManager(PROXY_URLS);
```

2. **Добавить retry с экспоненциальным backoff:**

```javascript
async function fetchWithRetry(url, options, maxRetries = 3) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const proxy = proxyManager.getNextProxy();
      const start = Date.now();
      
      const response = await fetchThroughProxy(url, options, proxy.url);
      
      const duration = Date.now() - start;
      proxyManager.recordSuccess(proxy.url, duration);
      
      return response;
    } catch (error) {
      proxyManager.recordFailure(proxy.url);
      
      if (attempt === maxRetries) throw error;
      
      // Exponential backoff: 1s, 2s, 4s
      const delay = Math.pow(2, attempt - 1) * 1000;
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}
```

3. **Добавить кеширование ответов:**

```javascript
const NodeCache = require('node-cache');
const cache = new NodeCache({ stdTTL: 300 }); // 5 минут

app.post('/openai/*', async (req, res) => {
  // Создаем ключ кеша
  const cacheKey = `${req.path}_${JSON.stringify(req.body)}`;
  
  // Проверяем кеш
  const cached = cache.get(cacheKey);
  if (cached) {
    console.log('✅ Cache hit');
    return res.json(cached);
  }
  
  // ... выполняем запрос
  
  // Сохраняем в кеш
  cache.set(cacheKey, data);
  res.json(data);
});
```

4. **Добавить rate limiting:**

```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 60 * 1000, // 1 минута
  max: 60, // 60 запросов в минуту
  message: 'Too many requests, please try again later'
});

app.use('/openai/*', limiter);
app.use('/gemini/*', limiter);
```

---

## Итоговые рекомендации

### Немедленные действия (критические):
1. ✅ Добавить HEALTHCHECK в Dockerfile.proxy
2. ✅ Исправить чтение переменных прокси
3. ✅ Исправить путь к Dockerfile в prod
4. ✅ Решить проблему с переменными для Flutter Web

### Краткосрочные действия (1-2 недели):
1. Реализовать логирование и мониторинг
2. Добавить retry механизм с backoff
3. Протестировать доступность SOCKS5 из Docker
4. Настроить health checks для всех сервисов

### Долгосрочные действия (1-2 месяца):
1. Рассмотреть миграцию на Cloudflare Workers
2. Или упростить архитектуру, убрав proxy-server
3. Добавить метрики и алерты
4. Реализовать A/B тестирование прокси

---

## Приоритезация

### 🔴 Критично (блокирует production):
- HEALTHCHECK в Dockerfile.proxy
- Переменные окружения для Flutter Web
- Конфликт приоритета прокси

### 🟡 Важно (влияет на reliability):
- Доступность SOCKS5 из Docker
- Native приложения не могут подключиться
- Отсутствие логирования

### 🟢 Желательно (улучшения):
- Упрощение архитектуры
- Кеширование
- Rate limiting
- Метрики

---

## Заключение

Текущая реализация системы прокси имеет **5 критических ошибок**, которые блокируют запуск production-версии.

**Самая критичная проблема** - отсутствие HEALTHCHECK и проблема с переменными окружения для Flutter Web.

**Рекомендуемый подход:**
1. Исправить критические ошибки (1-2 дня)
2. Запустить в production с текущей архитектурой
3. Собрать метрики и логи (1-2 недели)
4. Принять решение о рефакторинге архитектуры на основе данных

**Альтернативный подход (более быстрый):**
Сразу мигрировать на Cloudflare Workers - это упростит архитектуру и решит большинство проблем.

