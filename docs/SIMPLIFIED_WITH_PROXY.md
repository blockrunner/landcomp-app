# Упрощенная архитектура С ОБЯЗАТЕЛЬНЫМ ПРОКСИ

## Требование: прокси ОБЯЗАТЕЛЕН для API запросов

Это значит, что варианты БЕЗ прокси (прямое подключение) не подходят.

---

## Вариант A: Упрощаем текущую реализацию (РЕКОМЕНДУЕТСЯ)

**Сложность:** 🟢 Низкая  
**Время:** 2-4 часа  
**Риск:** 🟢 Минимальный

### Что упрощаем:

#### 1. Объединяем переменные прокси
```bash
# БЫЛО (в .env):
HTTP_PROXY=
HTTPS_PROXY=
ALL_PROXY=socks5h://user:pass@host:port
BACKUP_PROXIES=proxy1,proxy2

# СТАЛО:
PROXY_LIST=socks5h://user:pass@host1:port,socks5h://user:pass@host2:port
# Один список, без путаницы
```

#### 2. Упрощаем proxy-server.js
```javascript
// БЫЛО: сложная логика с HTTP_PROXY || ALL_PROXY
const RAW_PROXY_LIST = process.env.HTTP_PROXY || process.env.ALL_PROXY || '';

// СТАЛО: одна переменная
const PROXY_LIST = (process.env.PROXY_LIST || '')
  .split(',')
  .map(s => s.trim())
  .filter(s => s.length > 0);

console.log('🔧 Configured proxies:', PROXY_LIST.length);
PROXY_LIST.forEach((url, idx) => {
  const sanitized = url.replace(/:[^:@]+@/, ':****@');
  console.log(`   ${idx + 1}. ${sanitized}`);
});

// Убираем неиспользуемые функции:
// ❌ getCurrentProxyAgent() 
// ❌ getTestProxyAgent()
// ❌ switchToNextProxy()
// ❌ Обработка X-Proxy-* headers (не используются)
```

#### 3. Убираем неиспользуемые заголовки в Flutter
```dart
// lib/core/network/ai_service.dart

void _configureWebProxy(Uri proxyUri) {
  if (kIsWeb) {
    _dio.options.baseUrl = '';
  } else {
    final serverHost = EnvConfig.serverHost;
    _dio.options.baseUrl = serverHost.isNotEmpty 
        ? 'http://$serverHost:3001'
        : 'http://89.111.171.89:3001';
  }
  
  // ❌ УБИРАЕМ все X-Proxy-* headers
  // Прокси-сервер берет настройки из переменных окружения,
  // а не из заголовков запроса
}
```

#### 4. Упрощаем EnvConfig
```dart
// lib/core/config/env_config.dart

class EnvConfig {
  // Упрощаем - одна переменная для прокси
  static String get proxyList => _getEnvVar('PROXY_LIST');
  
  static List<String> get proxies {
    final list = proxyList;
    if (list.isEmpty) return [];
    return list
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
  }
  
  static String getCurrentProxy() {
    final list = proxies;
    return list.isNotEmpty ? list.first : '';
  }
  
  // ❌ УБИРАЕМ:
  // - allProxy
  // - backupProxies  
  // - getNextBackupProxy (логика уже в proxy-server)
}
```

#### 5. Упрощаем docker-compose
```yaml
# docker-compose.prod.yml
services:
  landcomp-proxy:
    build:
      context: ./proxy
      dockerfile: Dockerfile
    environment:
      # Одна переменная вместо трех
      - PROXY_LIST=${PROXY_LIST}
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3001/health"]
      interval: 15s
      timeout: 5s
      retries: 3
  
  landcomp-app:
    depends_on:
      landcomp-proxy:
        condition: service_healthy
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - GOOGLE_API_KEY=${GOOGLE_API_KEY}
      - GOOGLE_API_KEYS_FALLBACK=${GOOGLE_API_KEYS_FALLBACK}
      - PROXY_LIST=${PROXY_LIST}  # Для информации
      - SERVER_HOST=${SERVER_HOST}
```

### Результат:
```
БЫЛО:                          СТАЛО:
- 3 переменные прокси      →   - 1 переменная прокси
- X-Proxy-* headers        →   - Убрали
- Сложная логика выбора    →   - Promise.any в proxy-server
- Неиспользуемые функции   →   - Убрали
```

### Преимущества:
- ✅ Проще понять и поддерживать
- ✅ Меньше кода
- ✅ Меньше переменных окружения
- ✅ Та же функциональность
- ✅ Прокси сохранен (обязательное требование)

---

## Вариант B: Cloudflare Workers + Outbound Proxy

**Сложность:** 🟡 Средняя  
**Время:** 1-2 дня  
**Риск:** 🟡 Средний

### Идея:
Cloudflare Workers может использовать SOCKS5 прокси через внешний сервис!

### Архитектура:
```
Flutter (Web/Native)
    ↓
Cloudflare Worker
    ↓
Outbound SOCKS5 Proxy (через Cloudflare partner или свой сервис)
    ↓
AI API
```

### Реализация:

#### 1. Cloudflare Worker с прокси
```javascript
// worker.js
import { SocksClient } from 'socks';

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
    }
    
    const targetUrl = targetBase + url.pathname + url.search;
    
    // Делаем запрос через SOCKS5 прокси
    const proxyConfig = {
      proxy: {
        host: env.SOCKS_HOST,
        port: parseInt(env.SOCKS_PORT),
        type: 5,
        userId: env.SOCKS_USER,
        password: env.SOCKS_PASS
      },
      command: 'connect',
      destination: {
        host: new URL(targetBase).hostname,
        port: 443
      }
    };
    
    // Cloudflare Workers поддерживает TCP sockets!
    const info = await SocksClient.createConnection(proxyConfig);
    
    // Используем socket для HTTPS запроса
    const response = await fetch(targetUrl, {
      method: request.method,
      headers: request.headers,
      body: request.body,
      // @ts-ignore - Cloudflare Workers specific
      cf: {
        // Используем созданное соединение
        socket: info.socket
      }
    });
    
    return response;
  }
};
```

### Проблема:
⚠️ Cloudflare Workers **НЕ поддерживает** прямые TCP sockets для SOCKS5!

### Решение - вариант B.1: Proxy Gateway
Создать отдельный proxy gateway сервис:

```
Flutter → Cloudflare Worker → Proxy Gateway (ваш сервер) → SOCKS5 → API
```

Но это опять усложнение...

---

## Вариант C: Упрощаем ДО nginx (убираем Node.js)

**Сложность:** 🟡 Средняя  
**Время:** 6-8 часов  
**Риск:** 🟡 Средний

### Идея:
Использовать только Nginx + SOCKS5, без Node.js proxy-server.

### Проблема:
Nginx **НЕ поддерживает** SOCKS5 напрямую! Только HTTP/HTTPS proxy.

### Решение - вариант C.1: HTTP прокси вместо SOCKS5
Если у вас есть HTTP прокси (вместо SOCKS5):

```nginx
# nginx.conf
location /proxy/openai/ {
    proxy_pass https://api.openai.com/;
    
    # HTTP прокси
    proxy_http_version 1.1;
    proxy_set_header Host api.openai.com;
    
    # Через HTTP прокси
    proxy_pass_request_headers on;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

Но если прокси ТОЛЬКО SOCKS5 → Nginx не подходит.

---

## Вариант D: Dante SOCKS5 + Nginx

**Сложность:** 🔴 Высокая  
**Время:** 1-2 дня  
**Риск:** 🔴 Высокий

### Архитектура:
```
Flutter → Nginx → Dante SOCKS Client → SOCKS5 Proxy → AI API
```

### Dockerfile
```dockerfile
FROM nginx:alpine

# Установить Dante SOCKS client
RUN apk add --no-cache dante-client

# Настроить Dante
COPY dante.conf /etc/dante.conf

# Nginx конфиг
COPY nginx.conf /etc/nginx/nginx.conf

CMD ["sh", "-c", "sockd && nginx -g 'daemon off;'"]
```

### Проблема:
Очень сложная настройка, больше точек отказа.

---

## 🎯 РЕКОМЕНДАЦИЯ с учетом обязательного прокси

### Сейчас (сегодня):
**Применить Вариант A - Упрощение текущей реализации**

1. ✅ Применить критические исправления
2. ✅ Упростить код (один PROXY_LIST вместо трех переменных)
3. ✅ Убрать неиспользуемый код
4. ✅ Сохранить прокси (обязательное требование)

### Итоговая архитектура (упрощенная):
```
┌─────────────────────────────────────────────────────────┐
│ Flutter Web → Nginx → Proxy Server → SOCKS5 → AI API   │
│                                                          │
│ Flutter Native → Proxy Server → SOCKS5 → AI API        │
└─────────────────────────────────────────────────────────┘

УПРОЩЕНИЯ:
✅ PROXY_LIST вместо HTTP_PROXY/ALL_PROXY/BACKUP_PROXIES
✅ Убрали X-Proxy-* headers (не используются)
✅ Убрали неиспользуемые функции
✅ Упростили EnvConfig
✅ Улучшили логирование
```

### Что НЕ можем упростить (из-за SOCKS5):
- ❌ Убрать proxy-server (Nginx не поддерживает SOCKS5)
- ❌ Использовать только Cloudflare Workers (нет SOCKS5)
- ❌ Прямые запросы к API (требуется прокси)

---

## Готовые файлы для Варианта A

Хотите, чтобы я создал готовые файлы для упрощения?

Создам:
1. `debug/simplified-proxy-server.js` - упрощенный proxy-server
2. `debug/simplified-env.example` - упрощенные переменные
3. `debug/simplified-env_config.dart` - упрощенный EnvConfig
4. `debug/simplified-ai_service.dart` - убрать X-Proxy-* headers
5. `debug/apply-simplification.ps1` - скрипт применения

Создать эти файлы?

