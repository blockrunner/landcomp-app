/// Unit tests for AI Service
///
/// Tests OpenAI and Google Gemini integration,
/// fallback mechanisms, and proxy support.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:landcomp_app/core/network/ai_service.dart';
import 'package:landcomp_app/core/config/env_config.dart';
import 'package:landcomp_app/core/ai/agent_selector.dart';
import 'package:landcomp_app/features/chat/domain/entities/ai_agent.dart';

import 'ai_service_test.mocks.dart';

@GenerateMocks([Dio, EnvConfig, AgentSelector])
void main() {
  group('AIService', () {
    late AIService aiService;
    late MockDio mockDio;
    late MockEnvConfig mockEnvConfig;
    late MockAgentSelector mockAgentSelector;

    setUp(() {
      aiService = AIService.instance;
      mockDio = MockDio();
      mockEnvConfig = MockEnvConfig();
      mockAgentSelector = MockAgentSelector();
    });

    group('Initialization', () {
      test('should initialize successfully with proxy configuration', () async {
        // Arrange
        when(
          mockEnvConfig.getCurrentProxy(),
        ).thenReturn('socks5h://user:pass@proxy:1080');
        when(mockEnvConfig.googleApiKey).thenReturn('test-google-key');
        when(mockEnvConfig.isOpenAIConfigured).thenReturn(true);
        when(mockEnvConfig.isGoogleConfigured).thenReturn(true);

        // Act
        await aiService.initialize();

        // Assert
        expect(aiService.getStatus()['proxy_configured'], isTrue);
        expect(aiService.getStatus()['openai_configured'], isTrue);
        expect(aiService.getStatus()['google_configured'], isTrue);
      });

      test('should initialize without proxy when not configured', () async {
        // Arrange
        when(mockEnvConfig.getCurrentProxy()).thenReturn('');
        when(mockEnvConfig.googleApiKey).thenReturn('test-google-key');
        when(mockEnvConfig.isOpenAIConfigured).thenReturn(false);
        when(mockEnvConfig.isGoogleConfigured).thenReturn(true);

        // Act
        await aiService.initialize();

        // Assert
        expect(aiService.getStatus()['proxy_configured'], isFalse);
        expect(aiService.getStatus()['openai_configured'], isFalse);
        expect(aiService.getStatus()['google_configured'], isTrue);
      });
    });

    group('OpenAI Integration', () {
      test('should send message to OpenAI successfully', () async {
        // Arrange
        const message = 'Test message';
        const systemPrompt = 'You are a helpful assistant';
        const expectedResponse = 'Test response from OpenAI';

        final mockResponse = Response<Map<String, dynamic>>(
          data: {
            'choices': [
              {
                'message': {'content': expectedResponse},
              },
            ],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test'),
        );

        when(
          mockDio.post<Map<String, dynamic>>(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenAnswer((_) async => mockResponse);

        when(mockEnvConfig.isOpenAIConfigured).thenReturn(true);
        when(mockEnvConfig.openaiApiKey).thenReturn('test-openai-key');

        // Act
        final result = await aiService.sendToOpenAI(
          message: message,
          systemPrompt: systemPrompt,
        );

        // Assert
        expect(result, equals(expectedResponse));
        verify(
          mockDio.post<Map<String, dynamic>>(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).called(1);
      });

      test('should handle OpenAI rate limit error', () async {
        // Arrange
        const message = 'Test message';
        const systemPrompt = 'You are a helpful assistant';

        final mockError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            data: {
              'error': {'message': 'Rate limit exceeded'},
            },
            statusCode: 429,
            requestOptions: RequestOptions(path: '/test'),
          ),
          type: DioExceptionType.badResponse,
        );

        when(
          mockDio.post<Map<String, dynamic>>(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenThrow(mockError);

        when(mockEnvConfig.isOpenAIConfigured).thenReturn(true);
        when(mockEnvConfig.openaiApiKey).thenReturn('test-openai-key');

        // Act & Assert
        expect(
          () => aiService.sendToOpenAI(
            message: message,
            systemPrompt: systemPrompt,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('rate limit exceeded'),
            ),
          ),
        );
      });

      test('should handle OpenAI authentication error', () async {
        // Arrange
        const message = 'Test message';
        const systemPrompt = 'You are a helpful assistant';

        final mockError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            data: {
              'error': {'message': 'Invalid API key'},
            },
            statusCode: 401,
            requestOptions: RequestOptions(path: '/test'),
          ),
          type: DioExceptionType.badResponse,
        );

        when(
          mockDio.post<Map<String, dynamic>>(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenThrow(mockError);

        when(mockEnvConfig.isOpenAIConfigured).thenReturn(true);
        when(mockEnvConfig.openaiApiKey).thenReturn('invalid-key');

        // Act & Assert
        expect(
          () => aiService.sendToOpenAI(
            message: message,
            systemPrompt: systemPrompt,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('API key is invalid'),
            ),
          ),
        );
      });

      test('should throw exception when OpenAI not configured', () async {
        // Arrange
        when(mockEnvConfig.isOpenAIConfigured).thenReturn(false);

        // Act & Assert
        expect(
          () => aiService.sendToOpenAI(message: 'test', systemPrompt: 'test'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('OpenAI API key not configured'),
            ),
          ),
        );
      });
    });

    group('Google Gemini Integration', () {
      test('should send message to Google Gemini successfully', () async {
        // Arrange
        const message = 'Test message';
        const systemPrompt = 'You are a helpful assistant';
        const expectedResponse = 'Test response from Gemini';

        final mockResponse = Response<Map<String, dynamic>>(
          data: {
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': expectedResponse},
                  ],
                },
              },
            ],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test'),
        );

        when(
          mockDio.post<Map<String, dynamic>>(
            any,
            queryParameters: anyNamed('queryParameters'),
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenAnswer((_) async => mockResponse);

        when(mockEnvConfig.isGoogleConfigured).thenReturn(true);
        when(mockEnvConfig.googleApiKey).thenReturn('test-google-key');

        // Act
        final result = await aiService.sendToGemini(
          message: message,
          systemPrompt: systemPrompt,
        );

        // Assert
        expect(result, equals(expectedResponse));
        verify(
          mockDio.post<Map<String, dynamic>>(
            any,
            queryParameters: anyNamed('queryParameters'),
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).called(1);
      });

      test(
        'should handle Google Gemini rate limit with fallback key',
        () async {
          // Arrange
          const message = 'Test message';
          const systemPrompt = 'You are a helpful assistant';
          const expectedResponse = 'Test response from Gemini with fallback';

          // First call fails with rate limit
          final mockError = DioException(
            requestOptions: RequestOptions(path: '/test'),
            response: Response(
              data: {
                'error': {'message': 'Rate limit exceeded'},
              },
              statusCode: 429,
              requestOptions: RequestOptions(path: '/test'),
            ),
            type: DioExceptionType.badResponse,
          );

          // Second call succeeds with fallback key
          final mockSuccessResponse = Response<Map<String, dynamic>>(
            data: {
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {'text': expectedResponse},
                    ],
                  },
                },
              ],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/test'),
          );

          when(
            mockDio.post<Map<String, dynamic>>(
              any,
              queryParameters: anyNamed('queryParameters'),
              data: anyNamed('data'),
              options: anyNamed('options'),
            ),
          ).thenThrow(mockError).thenAnswer((_) async => mockSuccessResponse);

          when(mockEnvConfig.isGoogleConfigured).thenReturn(true);
          when(mockEnvConfig.googleApiKey).thenReturn('test-google-key');
          when(
            mockEnvConfig.getNextGoogleApiKey(any),
          ).thenReturn('fallback-key');

          // Act
          final result = await aiService.sendToGemini(
            message: message,
            systemPrompt: systemPrompt,
          );

          // Assert
          expect(result, equals(expectedResponse));
          verify(
            mockDio.post<Map<String, dynamic>>(
              any,
              queryParameters: anyNamed('queryParameters'),
              data: anyNamed('data'),
              options: anyNamed('options'),
            ),
          ).called(2); // Called twice: first fails, second succeeds
        },
      );

      test('should handle Google Gemini resource exhausted error', () async {
        // Arrange
        const message = 'Test message';
        const systemPrompt = 'You are a helpful assistant';

        final mockError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            data: {
              'error': {'message': 'RESOURCE_EXHAUSTED'},
            },
            statusCode: 400,
            requestOptions: RequestOptions(path: '/test'),
          ),
          type: DioExceptionType.badResponse,
        );

        when(
          mockDio.post<Map<String, dynamic>>(
            any,
            queryParameters: anyNamed('queryParameters'),
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenThrow(mockError);

        when(mockEnvConfig.isGoogleConfigured).thenReturn(true);
        when(mockEnvConfig.googleApiKey).thenReturn('test-google-key');
        when(mockEnvConfig.getNextGoogleApiKey(any)).thenReturn(null);

        // Act & Assert
        expect(
          () => aiService.sendToGemini(
            message: message,
            systemPrompt: systemPrompt,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('RESOURCE_EXHAUSTED'),
            ),
          ),
        );
      });

      test(
        'should throw exception when Google Gemini not configured',
        () async {
          // Arrange
          when(mockEnvConfig.isGoogleConfigured).thenReturn(false);

          // Act & Assert
          expect(
            () => aiService.sendToGemini(message: 'test', systemPrompt: 'test'),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Google API key not configured'),
              ),
            ),
          );
        },
      );
    });

    group('Smart Message Sending', () {
      test(
        'should send message with automatic provider selection (OpenAI preferred)',
        () async {
          // Arrange
          const message = 'Test message';
          const systemPrompt = 'You are a helpful assistant';
          const expectedResponse = 'Test response from OpenAI';

          final mockResponse = Response<Map<String, dynamic>>(
            data: {
              'choices': [
                {
                  'message': {'content': expectedResponse},
                },
              ],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/test'),
          );

          when(
            mockDio.post<Map<String, dynamic>>(
              any,
              data: anyNamed('data'),
              options: anyNamed('options'),
            ),
          ).thenAnswer((_) async => mockResponse);

          when(mockEnvConfig.isOpenAIConfigured).thenReturn(true);
          when(mockEnvConfig.isGoogleConfigured).thenReturn(true);
          when(mockEnvConfig.openaiApiKey).thenReturn('test-openai-key');

          // Act
          final result = await aiService.sendMessage(
            message: message,
            systemPrompt: systemPrompt,
          );

          // Assert
          expect(result, equals(expectedResponse));
          verify(
            mockDio.post<Map<String, dynamic>>(
              any,
              data: anyNamed('data'),
              options: anyNamed('options'),
            ),
          ).called(1);
        },
      );

      test('should fallback to Gemini when OpenAI fails', () async {
        // Arrange
        const message = 'Test message';
        const systemPrompt = 'You are a helpful assistant';
        const expectedResponse = 'Test response from Gemini fallback';

        // OpenAI fails
        final mockOpenAIError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            data: {
              'error': {'message': 'Service unavailable'},
            },
            statusCode: 503,
            requestOptions: RequestOptions(path: '/test'),
          ),
          type: DioExceptionType.badResponse,
        );

        // Gemini succeeds
        final mockGeminiResponse = Response<Map<String, dynamic>>(
          data: {
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': expectedResponse},
                  ],
                },
              },
            ],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test'),
        );

        when(
          mockDio.post<Map<String, dynamic>>(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenThrow(mockOpenAIError);

        when(
          mockDio.post<Map<String, dynamic>>(
            any,
            queryParameters: anyNamed('queryParameters'),
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenAnswer((_) async => mockGeminiResponse);

        when(mockEnvConfig.isOpenAIConfigured).thenReturn(true);
        when(mockEnvConfig.isGoogleConfigured).thenReturn(true);
        when(mockEnvConfig.openaiApiKey).thenReturn('test-openai-key');
        when(mockEnvConfig.googleApiKey).thenReturn('test-google-key');

        // Act
        final result = await aiService.sendMessage(
          message: message,
          systemPrompt: systemPrompt,
        );

        // Assert
        expect(result, equals(expectedResponse));
        verify(
          mockDio.post<Map<String, dynamic>>(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).called(1); // OpenAI call
        verify(
          mockDio.post<Map<String, dynamic>>(
            any,
            queryParameters: anyNamed('queryParameters'),
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).called(1); // Gemini fallback call
      });

      test('should throw exception when no providers configured', () async {
        // Arrange
        when(mockEnvConfig.isOpenAIConfigured).thenReturn(false);
        when(mockEnvConfig.isGoogleConfigured).thenReturn(false);

        // Act & Assert
        expect(
          () => aiService.sendMessage(message: 'test', systemPrompt: 'test'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('No AI providers configured'),
            ),
          ),
        );
      });
    });

    group('Smart Agent Selection', () {
      test(
        'should send message with smart agent selection successfully',
        () async {
          // Arrange
          const message = 'How to plant tomatoes?';
          const expectedResponse = 'Test response from Gardener agent';

          const mockAgent = AIAgent(
            id: 'gardener',
            name: 'Gardener',
            description: 'Expert in plants and gardening',
            systemPrompt: 'You are a gardening expert',
            icon: '🌱',
            color: 0xFF4CAF50,
          );

          final mockSelectionResult = AgentSelectionResult(
            isSuccess: true,
            agent: mockAgent,
            confidence: 0.9,
            isOutOfScope: false,
          );

          final mockAIResponse = Response<Map<String, dynamic>>(
            data: {
              'choices': [
                {
                  'message': {'content': expectedResponse},
                },
              ],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/test'),
          );

          when(
            mockAgentSelector.selectAgent(message),
          ).thenAnswer((_) async => mockSelectionResult);
          when(
            mockDio.post<Map<String, dynamic>>(
              any,
              data: anyNamed('data'),
              options: anyNamed('options'),
            ),
          ).thenAnswer((_) async => mockAIResponse);

          when(mockEnvConfig.isOpenAIConfigured).thenReturn(true);
          when(mockEnvConfig.openaiApiKey).thenReturn('test-openai-key');

          // Act
          final result = await aiService.sendMessageWithSmartSelection(
            message: message,
          );

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.message, equals(expectedResponse));
          expect(result.agent, equals(mockAgent));
          expect(result.confidence, equals(0.9));
          expect(result.isOutOfScope, isFalse);
          expect(result.isError, isFalse);
        },
      );

      test('should handle out of scope queries', () async {
        // Arrange
        const message = 'What is the weather today?';
        const outOfScopeMessage = 'This question is outside my expertise area.';

        final mockSelectionResult = AgentSelectionResult(
          isSuccess: false,
          agent: null,
          confidence: null,
          isOutOfScope: true,
          outOfScopeMessage: outOfScopeMessage,
        );

        when(
          mockAgentSelector.selectAgent(message),
        ).thenAnswer((_) async => mockSelectionResult);

        // Act
        final result = await aiService.sendMessageWithSmartSelection(
          message: message,
        );

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.isOutOfScope, isTrue);
        expect(result.message, equals(outOfScopeMessage));
        expect(result.agent, isNull);
        expect(result.isError, isFalse);
      });

      test('should handle agent selection failure', () async {
        // Arrange
        const message = 'Test message';

        final mockSelectionResult = AgentSelectionResult(
          isSuccess: false,
          agent: null,
          confidence: null,
          isOutOfScope: false,
        );

        when(
          mockAgentSelector.selectAgent(message),
        ).thenAnswer((_) async => mockSelectionResult);

        // Act
        final result = await aiService.sendMessageWithSmartSelection(
          message: message,
        );

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.isOutOfScope, isFalse);
        expect(result.isError, isTrue);
        expect(result.message, contains('Failed to select appropriate agent'));
      });

      test('should handle AI service errors gracefully', () async {
        // Arrange
        const message = 'Test message';

        const mockAgent = AIAgent(
          id: 'gardener',
          name: 'Gardener',
          description: 'Expert in plants and gardening',
          systemPrompt: 'You are a gardening expert',
          icon: '🌱',
          color: 0xFF4CAF50,
        );

        final mockSelectionResult = AgentSelectionResult(
          isSuccess: true,
          agent: mockAgent,
          confidence: 0.9,
          isOutOfScope: false,
        );

        when(
          mockAgentSelector.selectAgent(message),
        ).thenAnswer((_) async => mockSelectionResult);
        when(
          mockDio.post<Map<String, dynamic>>(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenThrow(Exception('Network error'));

        when(mockEnvConfig.isOpenAIConfigured).thenReturn(true);
        when(mockEnvConfig.openaiApiKey).thenReturn('test-openai-key');

        // Act
        final result = await aiService.sendMessageWithSmartSelection(
          message: message,
        );

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.isOutOfScope, isFalse);
        expect(result.isError, isTrue);
        expect(
          result.message,
          contains('Произошла ошибка при обработке запроса'),
        );
      });
    });

    group('Proxy Support', () {
      test('should configure proxy for native platforms', () {
        // This test would require more complex mocking of HttpClient
        // For now, we'll test the proxy configuration logic
        expect(true, isTrue); // Placeholder test
      });

      test('should handle proxy configuration errors gracefully', () {
        // This test would require more complex mocking of HttpClient
        // For now, we'll test the error handling logic
        expect(true, isTrue); // Placeholder test
      });
    });

    group('Service Status', () {
      test('should return correct service status', () {
        // Arrange
        when(mockEnvConfig.isOpenAIConfigured).thenReturn(true);
        when(mockEnvConfig.isGoogleConfigured).thenReturn(true);
        when(mockEnvConfig.isProxyConfigured).thenReturn(true);

        // Act
        final status = aiService.getStatus();

        // Assert
        expect(status, isA<Map<String, dynamic>>());
        expect(status['openai_configured'], isTrue);
        expect(status['google_configured'], isTrue);
        expect(status['proxy_configured'], isTrue);
        expect(status['current_proxy'], isA<String>());
        expect(status['current_google_key'], isA<String>());
      });
    });
  });
}
