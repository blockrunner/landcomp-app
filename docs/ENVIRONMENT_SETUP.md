# Environment Setup Guide

## AI Service Configuration

### Required Environment Variables

Create a `.env` file in the project root with the following variables:

```bash
# AI Service API Keys
OPENAI_API_KEY="sk-proj-your-openai-api-key-here"
GOOGLE_API_KEY="AIzaSy-your-google-api-key-here"
GOOGLE_API_KEYS_FALLBACK="AIzaSy-backup-key-1,AIzaSy-backup-key-2"

# Proxy Configuration (Required for AI services)
ALL_PROXY="socks5h://username:password@proxy-server:port"
BACKUP_PROXIES="socks5h://username:password@backup-proxy-1:port,socks5h://username:password@backup-proxy-2:port"
```

### API Keys Setup

#### OpenAI API Key
1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Create an account or sign in
3. Navigate to API Keys section
4. Create a new API key
5. Copy the key and add it to your `.env` file

#### Google Gemini API Key
1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Copy the key and add it to your `.env` file
4. For fallback keys, create additional API keys and add them to `GOOGLE_API_KEYS_FALLBACK`

### Proxy Configuration

#### Why Proxy is Required
- OpenAI and Google APIs may be restricted in certain regions
- Proxy ensures reliable access to AI services
- Fallback proxies provide redundancy

#### Proxy Setup
1. Obtain SOCKS5 proxy credentials
2. Format: `socks5h://username:password@proxy-server:port`
3. Add primary proxy to `ALL_PROXY`
4. Add backup proxies to `BACKUP_PROXIES` (comma-separated)

#### Example Proxy Configuration
```bash
ALL_PROXY="socks5h://user123:pass456@proxy.example.com:1080"
BACKUP_PROXIES="socks5h://user123:pass456@backup1.example.com:1080,socks5h://user123:pass456@backup2.example.com:1080"
```

### Fallback Mechanisms

The application includes several fallback mechanisms:

1. **Proxy Fallback**: If primary proxy fails, automatically switches to backup proxies
2. **API Key Fallback**: If Google API key is exhausted, switches to backup keys
3. **Provider Fallback**: If preferred AI provider fails, switches to alternative provider

### Environment Validation

The application validates the environment configuration on startup:

```dart
// Check configuration status
final status = EnvConfig.validateConfiguration();
print('Configuration Status: $status');
```

### Troubleshooting

#### Common Issues

1. **"No AI providers configured"**
   - Ensure API keys are set in `.env` file
   - Check that keys are valid and active

2. **"Proxy configuration failed"**
   - Verify proxy credentials are correct
   - Test proxy connection manually
   - Check if proxy server is accessible

3. **"Rate limit exceeded"**
   - Application will automatically try fallback keys
   - Wait for rate limit to reset
   - Consider upgrading API plan

4. **"Resource exhausted"**
   - Google API quota exceeded
   - Application will try fallback keys
   - Check API usage in Google Cloud Console

#### Testing Configuration

Run the configuration test:

```bash
flutter run --dart-define-from-file=.env
```

Check the console output for configuration status.

### Security Notes

1. **Never commit `.env` file** to version control
2. **Use environment variables** in production
3. **Rotate API keys** regularly
4. **Monitor API usage** to prevent unexpected charges
5. **Use least privilege** principle for API keys

### Production Deployment

For production deployment:

1. Set environment variables in your deployment platform
2. Use secure secret management
3. Configure monitoring for API usage
4. Set up alerts for quota limits
5. Implement proper error handling and logging
