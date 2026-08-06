import 'dart:convert';
import 'dart:io';

class VoiceOpenAiTransport {
  const VoiceOpenAiTransport({
    required this.apiKey,
    this.baseUrl = 'https://api.openai.com/v1',
    HttpClient? client,
  }) : _client = client;

  final String? apiKey;
  final String baseUrl;
  final HttpClient? _client;

  bool get isReady => apiKey?.trim().isNotEmpty == true;

  Future<String> completeText({
    required String model,
    required String instructions,
    required String input,
  }) async {
    final response = await _postJson(
      path: '/responses',
      body: <String, Object?>{
        'model': model,
        'instructions': instructions,
        'input': input,
        'store': false,
      },
    );
    return _extractOutputText(response);
  }

  Future<Map<String, dynamic>> completeJson({
    required String model,
    required String instructions,
    required String input,
  }) async {
    final text = await completeText(
      model: model,
      instructions: instructions,
      input: input,
    );
    final decoded = jsonDecode(text);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw const FormatException(
      'OpenAI response did not return a JSON object.',
    );
  }

  Future<Map<String, dynamic>> _postJson({
    required String path,
    required Map<String, Object?> body,
  }) async {
    final client = _client ?? HttpClient();
    final request = await client.postUrl(Uri.parse('$baseUrl$path'));
    request.headers.contentType = ContentType.json;
    final key = apiKey?.trim();
    if (key != null && key.isNotEmpty) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $key');
    }
    request.add(utf8.encode(jsonEncode(body)));

    final response = await request.close();
    final responseBody = await utf8.decodeStream(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'OpenAI request failed with status ${response.statusCode}: $responseBody',
      );
    }

    final decoded = jsonDecode(responseBody);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw const FormatException('Unexpected OpenAI response format.');
  }

  String _extractOutputText(Map<String, dynamic> response) {
    final outputText = response['output_text'];
    if (outputText is String && outputText.trim().isNotEmpty) {
      return outputText.trim();
    }

    final output = response['output'];
    if (output is List) {
      final buffer = StringBuffer();
      for (final item in output.whereType<Map>()) {
        final map = Map<String, dynamic>.from(item);
        final content = map['content'];
        if (content is List) {
          for (final entry in content.whereType<Map>()) {
            final contentMap = Map<String, dynamic>.from(entry);
            final type = contentMap['type']?.toString();
            final text = contentMap['text']?.toString();
            if ((type == 'output_text' || type == 'text') &&
                text != null &&
                text.trim().isNotEmpty) {
              if (buffer.isNotEmpty) {
                buffer.write('\n');
              }
              buffer.write(text.trim());
            }
          }
        }
      }

      final extracted = buffer.toString().trim();
      if (extracted.isNotEmpty) {
        return extracted;
      }
    }

    throw const FormatException('OpenAI response did not include text output.');
  }
}
