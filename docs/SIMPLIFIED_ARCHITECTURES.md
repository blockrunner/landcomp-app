# Упрощенные варианты архитектуры прокси-системы

## Анализ: что можно упростить?

### Текущая проблема:
```
Flutter Web → Nginx → Proxy Server (Node.js) → SOCKS5 → AI API
                ↓
          4 уровня проксирования
          4 точки отказа
          Сложная отладка
```

### Вопросы для упрощения:

1. **Нужен ли SOCKS5 прокси?**
   - ❓ Если AI APIs доступны напрямую → можно убрать всю прокси-систему
   - ❓ Если нужен только для обхода блокировок → есть альтернативы

2. **Нужен ли Node.js proxy-server?**
   - ❓ Nginx может проксировать напрямую (без SOCKS5)
   - ❓ Для SOCKS5 можно использовать Nginx Stream module

3. **Можно ли упростить для Flutter Web?**
   - ✅ Да, можно убрать отдельный proxy-server
   - ✅ Использовать только Nginx или Cloudflare

---

## Вариант 1: Минимальные изменения (самый простой)

**Сложность:** 🟢 Низкая  
**Время:** 1-2 часа  
**Риск:** 🟢 Минимальный

### Что делаем:
- Убираем неиспользуемые X-Proxy-* заголовки
- Упрощаем логику чтения переменных
- Объединяем переменные (только ALL_PROXY)

### Изменения:

#### 1. Упрощаем env.example
```bash
# Только необходимые переменные
OPENAI_API_KEY=your_key
GOOGLE_API_KEY=your_key
GOOGLE_API_KEYS_FALLBACK=key1,key2

# Упрощенный прокси (только один)
ALL_PROXY=socks5h://user:pass@host:port
BACKUP_PROXIES=socks5h://user:pass@backup1:port,socks5h://user:pass@backup2:port

# Убираем неиспользуемые:
# ❌ HTTP_PROXY - не нужен, дублирует ALL_PROXY
# ❌ HTTPS_PROXY - не нужен, дублирует ALL_PROXY
# ❌ Другие API ключи (если не используются)
```

#### 2. Упрощаем ai_service.dart
```dart
void _configureWebProxy(Uri proxyUri) {
  if (kIsWeb) {
    // Для web - только относительные URL через nginx
    _dio.options.baseUrl = '';
  } else {
    // Для native - прямо к proxy server
    _dio.options.baseUrl = 'http://${EnvConfig.serverHost}:3001';
  }
  
  // ❌ УБИРАЕМ неиспользуемые заголовки X-Proxy-*
  // Прокси-сервер их все равно не читает
}
```

#### 3. Упрощаем proxy-server.js
```javascript
// Убираем сложную логику, оставляем только ALL_PROXY
const PROXY_URLS = (process.env.ALL_PROXY || '')
  .split(',')
  .map(s => s.trim())
  .filter(s => s.length > 0);

// Убираем неиспользуемые функции
// ❌ getCurrentProxyAgent() - не используется
// ❌ getTestProxyAgent() - не используется
// ❌ switchToNextProxy() - используется fetchThroughProxies
```

### Результат:
- ✅ Меньше кода
- ✅ Проще понять
- ✅ Меньше переменных окружения
- ✅ Та же функциональность

---

## Вариант 2: Убрать proxy-server для Web (рекомендуется)

**Сложность:** 🟡 Средняя  
**Время:** 4-6 часов  
**Риск:** 🟡 Средний

### Идея:
Для Flutter Web не нужен отдельный proxy-server - браузер сам умеет делать CORS запросы!

### Архитектура:

```
┌─────────────────────────────────────────────────┐
│ Flutter Web                                     │
│   ↓                                             │
│ Nginx (раздает статику)                        │
│   ↓                                             │
│ Прямые запросы к AI API (через CORS)          │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│ Flutter Native                                  │
│   ↓                                             │
│ Встроенный SOCKS5 прокси в HttpClient          │
│   ↓                                             │
│ Прямые запросы к AI API                        │
└─────────────────────────────────────────────────┘
```

### Изменения:

#### 1. Убрать proxy-server из docker-compose.prod.yml
```yaml
version: '3.8'

services:
  # ❌ УБИРАЕМ landcomp-proxy
  
  landcomp-app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "80:80"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - GOOGLE_API_KEY=${GOOGLE_API_KEY}
      # Прокси переменные только для native
      - ALL_PROXY=${ALL_PROXY}
    # ❌ УБИРАЕМ depends_on: landcomp-proxy
```

#### 2. Упростить nginx.conf
```nginx
server {
    listen 80;
    
    # Раздаем статику
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # ❌ УБИРАЕМ location /proxy/
    # Web делает запросы напрямую к AI API
}
```

#### 3. Обновить ai_service.dart
```dart
void _configureProxy() {
  if (kIsWeb) {
    // Для web - прямые запросы (браузер обрабатывает CORS)
    _dio.options.baseUrl = '';
    _dio.httpClientAdapter = BrowserHttpClientAdapter();
    // Браузер сам управляет прокси через системные настройки
  } else {
    // Для native - настраиваем SOCKS5 прокси
    _dio.options.baseUrl = '';
    _configureNativeProxy();
  }
}

void _configureNativeProxy() {
  final proxyUrl = EnvConfig.allProxy;
  if (proxyUrl.isEmpty) return;
  
  (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    final uri = Uri.parse(proxyUrl);
    
    client.findProxy = (uri) => 'PROXY ${uri.host}:${uri.port}';
    
    // Аутентификация если есть
    if (uri.userInfo.isNotEmpty) {
      final parts = uri.userInfo.split(':');
      client.authenticate = (_, scheme, realm) async {
        client.addCredentials(
          uri,
          scheme,
          HttpClientBasicCredentials(parts[0], parts[1]),
        );
        return true;
      };
    }
    
    return client;
  };
}

Future<String> sendToOpenAI({...}) async {
  // Прямой URL для всех платформ
  const url = 'https://api.openai.com/v1/chat/completions';
  
  // Запрос идет:
  // - Web: через браузер (CORS), прокси = системный
  // - Native: через HttpClient с SOCKS5
  final response = await _dio.post(url, ...);
  // ...
}
```

### Преимущества:
- ✅ Убрали Node.js proxy-server
- ✅ Убрали Docker контейнер
- ✅ Упростили nginx
- ✅ 3 уровня → 2 уровня
- ✅ Меньше точек отказа
- ✅ Проще отладка

### Недостатки:
- ⚠️ CORS могут заблокировать запросы (нужно проверить)
- ⚠️ Для Web прокси = системный прокси браузера
- ⚠️ Нельзя динамически менять прокси для Web

### Когда подходит:
- ✅ AI API доступны напрямую (без блокировок)
- ✅ CORS разрешены для вашего домена
- ✅ Web использует системный прокси браузера

---

## Вариант 3: Nginx Stream для SOCKS5 (без Node.js)

**Сложность:** 🟡 Средняя  
**Время:** 6-8 часов  
**Риск:** 🟡 Средний

### Идея:
Использовать Nginx Stream module для проксирования через SOCKS5 - без Node.js!

### Архитектура:
```
Flutter Web → Nginx (HTTP) → Nginx Stream (SOCKS5) → AI API
Flutter Native → Nginx Stream (SOCKS5) → AI API
```

### Изменения:

#### 1. Dockerfile для Nginx с Stream module
```dockerfile
# Используем nginx с stream module
FROM nginx:alpine

# Установить sockd или dante для SOCKS5
RUN apk add --no-cache dante-server

# Копируем конфигурацию
COPY nginx-stream.conf /etc/nginx/nginx.conf
COPY dante.conf /etc/dante.conf

# Скрипт запуска
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
```

#### 2. nginx-stream.conf
```nginx
stream {
    # Upstream для SOCKS5
    upstream socks5_proxy {
        server your-socks5-host:port;
    }
    
    # TCP прокси для OpenAI
    server {
        listen 8443;
        proxy_pass socks5_proxy;
        proxy_connect_timeout 30s;
    }
}

http {
    server {
        listen 80;
        
        location / {
            try_files $uri $uri/ /index.html;
        }
        
        # Проксируем через Stream
        location /proxy/openai/ {
            proxy_pass https://127.0.0.1:8443/;
            # ... headers
        }
    }
}
```

### Преимущества:
- ✅ Убрали Node.js
- ✅ Один контейнер вместо двух
- ✅ Nginx быстрее Node.js

### Недостатки:
- ⚠️ Сложнее настроить
- ⚠️ Nginx Stream не поддерживает SOCKS5 напрямую
- ⚠️ Нужен дополнительный SOCKS5 клиент (dante/sockd)

---

## Вариант 4: Cloudflare Workers (максимальное упрощение)

**Сложность:** 🟢 Низкая (просто другой подход)  
**Время:** 4-8 часов  
**Риск:** 🟢 Низкий

### Архитектура:
```
Flutter (Web/Native) → Cloudflare Worker → AI API
                 ↓
          1 промежуточный уровень
          Глобальный CDN
          Автомасштабирование
```

### Реализация:

#### 1. Cloudflare Worker
```javascript
// worker.js
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
      return new Response('Not Found', { status: 404 });
    }
    
    const targetUrl = targetBase + url.pathname + url.search;
    
    // Форвардим запрос
    const newRequest = new Request(targetUrl, {
      method: request.method,
      headers: request.headers,
      body: request.body,
    });
    
    const response = await fetch(newRequest);
    
    // Добавляем CORS
    const newResponse = new Response(response.body, response);
    newResponse.headers.set('Access-Control-Allow-Origin', '*');
    newResponse.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    newResponse.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    
    return newResponse;
  }
};
```

#### 2. Flutter изменения
```dart
class AIService {
  Future<void> initialize() async {
    _dio = Dio();
    
    // Единый URL для всех платформ
    _dio.options.baseUrl = 'https://api.landcomp.com';
    
    // Все запросы идут через Cloudflare Worker
    // Никаких сложных настроек прокси!
  }
  
  Future<String> sendToOpenAI({...}) async {
    // Просто добавляем префикс /openai
    final response = await _dio.post(
      '/openai/v1/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${EnvConfig.openaiApiKey}',
          'Content-Type': 'application/json',
        },
      ),
      data: {...},
    );
    // ...
  }
}
```

#### 3. Docker - ТОЛЬКО nginx для статики
```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  landcomp-app:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./build/web:/usr/share/nginx/html
      - ./nginx-simple.conf:/etc/nginx/nginx.conf
```

#### 4. nginx-simple.conf
```nginx
server {
    listen 80;
    
    # Только статика
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Все API запросы идут через Cloudflare
    # Nginx их не обрабатывает!
}
```

### Преимущества:
- ✅ **Максимальное упрощение** - убрали proxy-server, SOCKS5, сложные настройки
- ✅ **Глобальный CDN** - 200+ точек присутствия
- ✅ **Автомасштабирование** - без настроек
- ✅ **Бесплатно** - до 100K запросов/день
- ✅ **Единый URL** - для web и native
- ✅ **Встроенная защита** - DDoS, WAF, rate limiting
- ✅ **Простая отладка** - логи в Cloudflare Dashboard

### Недостатки:
- ⚠️ Зависимость от Cloudflare
- ⚠️ Требует настройку Custom Domain
- ⚠️ Нет SOCKS5 (если критично важен)

---

## Вариант 5: Гибридный (Web → Cloudflare, Native → SOCKS5)

**Сложность:** 🟡 Средняя  
**Время:** 6-10 часов  
**Риск:** 🟡 Средний

### Идея:
Разделить логику для Web и Native:
- **Web** → Cloudflare Worker (просто и быстро)
- **Native** → SOCKS5 через HttpClient (полный контроль)

### Архитектура:
```
┌─────────────────────────────────────────────┐
│ Flutter Web                                 │
│   ↓                                         │
│ Cloudflare Worker                          │
│   ↓                                         │
│ AI API                                      │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ Flutter Native                              │
│   ↓                                         │
│ HttpClient с SOCKS5                        │
│   ↓                                         │
│ AI API                                      │
└─────────────────────────────────────────────┘
```

### Реализация:
```dart
class AIService {
  Future<void> initialize() async {
    _dio = Dio();
    
    if (kIsWeb) {
      // Web: через Cloudflare Worker
      _dio.options.baseUrl = 'https://api.landcomp.com';
      _dio.httpClientAdapter = BrowserHttpClientAdapter();
    } else {
      // Native: прямо к API через SOCKS5
      _dio.options.baseUrl = '';
      _configureNativeProxy();
    }
  }
  
  Future<String> sendToOpenAI({...}) async {
    final url = kIsWeb
        ? '/openai/v1/chat/completions'
        : 'https://api.openai.com/v1/chat/completions';
    
    // ...
  }
}
```

### Преимущества:
- ✅ Лучшее из двух миров
- ✅ Web - просто и быстро
- ✅ Native - полный контроль
- ✅ Убрали proxy-server
- ✅ Убрали Docker контейнер

---

## Рекомендация: что выбрать?

### Если нужно БЫСТРО исправить (сегодня):
➡️ **Вариант 1** - Минимальные изменения  
- Применяем критические исправления
- Убираем лишний код
- Запускаем в production

### Если есть 1 день:
➡️ **Вариант 4** - Cloudflare Workers  
- Максимально упрощает архитектуру
- Убирает большинство проблем
- Дает дополнительные преимущества (CDN, масштабирование)

### Если SOCKS5 критично важен:
➡️ **Вариант 5** - Гибридный  
- Web через Cloudflare (просто)
- Native через SOCKS5 (контроль)
- Убираем proxy-server

### Если AI API доступны напрямую:
➡️ **Вариант 2** - Убрать proxy-server  
- Прямые запросы к API
- Системный прокси браузера для Web
- SOCKS5 в HttpClient для Native

---

## План действий

### Шаг 1: Сейчас (сегодня)
```bash
# Применяем критические исправления
.\debug\apply-fixes.ps1

# Запускаем
docker-compose -f docker-compose.prod.yml up -d

# Проверяем
docker ps
curl http://localhost/env.js
```

### Шаг 2: Собираем данные (1-2 дня)
- Смотрим логи
- Проверяем доступность AI API
- Проверяем нужен ли SOCKS5
- Смотрим метрики

### Шаг 3: Принимаем решение (через неделю)
На основе данных выбираем один из вариантов упрощения

### Шаг 4: Реализуем (1-2 дня)
Внедряем выбранный вариант

---

## Сравнительная таблица

| Критерий | Вариант 1 | Вариант 2 | Вариант 3 | Вариант 4 | Вариант 5 |
|----------|-----------|-----------|-----------|-----------|-----------|
| **Сложность** | 🟢 Низкая | 🟡 Средняя | 🟡 Средняя | 🟢 Низкая | 🟡 Средняя |
| **Время** | 1-2ч | 4-6ч | 6-8ч | 4-8ч | 6-10ч |
| **Упрощение** | 🟡 Среднее | 🟢 Высокое | 🟡 Среднее | 🟢 Максимум | 🟢 Высокое |
| **SOCKS5** | ✅ Да | ✅ Да (native) | ✅ Да | ❌ Нет | ✅ Да (native) |
| **Proxy Server** | ✅ Есть | ❌ Убрали | ❌ Убрали | ❌ Убрали | ❌ Убрали |
| **CDN** | ❌ Нет | ❌ Нет | ❌ Нет | ✅ Да | ✅ Да (web) |
| **Стоимость** | 🟡 SOCKS5 | 🟡 SOCKS5 | 🟡 SOCKS5 | 🟢 Бесплатно* | 🟡 SOCKS5 |
| **Риск** | 🟢 Минимум | 🟡 Средний | 🟡 Средний | 🟢 Низкий | 🟡 Средний |
| **Рекомендация** | ⭐ Сейчас | - | - | ⭐⭐⭐ Лучший | ⭐⭐ Если нужен SOCKS5 |

---

## Итоговая рекомендация

### Краткосрочно (сегодня):
✅ **Вариант 1** - минимальные изменения для быстрого запуска

### Среднесрочно (через неделю):
✅ **Вариант 4** - миграция на Cloudflare Workers

**Почему Cloudflare Workers?**
- Максимально упрощает архитектуру (2 уровня вместо 4)
- Убирает 80% текущих проблем
- Добавляет мощные возможности (CDN, масштабирование, защита)
- Время внедрения всего 4-8 часов
- Практически бесплатно

Хотите, создам готовые файлы для выбранного варианта упрощения?

