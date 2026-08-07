import 'dart:async';
import 'dart:convert';
import 'dart:io';

class GaiaCommand {
  GaiaCommand({
    this.source = 'gaia',
    required this.intent,
    required this.module,
    required this.action,
    Map<String, dynamic>? payload,
    this.requiresConfirmation = false,
    this.sensitivity = 'low',
  }) : payload = payload ?? <String, dynamic>{};

  final String source;
  final String intent;
  final String module;
  final String action;
  final Map<String, dynamic> payload;
  final bool requiresConfirmation;
  final String sensitivity;

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'intent': intent,
      'module': module,
      'action': action,
      'payload': payload,
      'requires_confirmation': requiresConfirmation,
      'sensitivity': sensitivity,
    };
  }
}

class GaiaDecision {
  GaiaDecision({required this.decision, this.reason = ''});

  final String decision;
  final String reason;

  bool get isAllowed => decision.toLowerCase() == 'allow';
  bool get isConfirm => decision.toLowerCase() == 'confirm';
  bool get isBlocked => decision.toLowerCase() == 'blocked';

  factory GaiaDecision.fromJson(Map<String, dynamic> json) {
    return GaiaDecision(
      decision: json['decision']?.toString() ?? 'allow',
      reason: json['reason']?.toString() ?? '',
    );
  }
}

class GaiaConversationResponse {
  GaiaConversationResponse({
    required this.reply,
    required this.status,
    this.reason,
  });

  final String reply;
  final String status;
  final String? reason;

  factory GaiaConversationResponse.fromJson(Map<String, dynamic> json) {
    return GaiaConversationResponse(
      reply: json['reply']?.toString() ?? '',
      status: json['status']?.toString() ?? 'ok',
      reason: json['reason']?.toString(),
    );
  }
}

class GaiaBridge {
  GaiaBridge({Uri? baseUri})
    : baseUri = baseUri ?? Uri.parse('http://127.0.0.1:8765'),
      _client = HttpClient()..connectionTimeout = const Duration(seconds: 8);

  final Uri baseUri;
  final HttpClient _client;

  Future<GaiaDecision> sendCommand(GaiaCommand command) async {
    final uri = baseUri.replace(path: '/command');
    final request = await _client.postUrl(uri);
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(command.toJson()));

    final response = await request.close().timeout(const Duration(seconds: 30));
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode != 200) {
      throw HttpException(
        'GAIA bridge returned ${response.statusCode}',
        uri: uri,
      );
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('GAIA bridge returned invalid JSON');
    }

    return GaiaDecision.fromJson(decoded);
  }

  Future<GaiaConversationResponse> sendConversationRequest(
    String query, {
    String transcript = '',
    Map<String, dynamic>? context,
  }) async {
    final uri = baseUri.replace(path: '/conversation');
    final request = await _client.postUrl(uri);
    request.headers.contentType = ContentType.json;
    request.write(
      jsonEncode({
        'query': query,
        'transcript': transcript,
        'context': context ?? {},
      }),
    );

    final response = await request.close().timeout(const Duration(seconds: 30));
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode != 200) {
      throw HttpException(
        'GAIA bridge returned ${response.statusCode}',
        uri: uri,
      );
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('GAIA bridge returned invalid JSON');
    }

    final conversation = decoded['conversation'];
    if (conversation is! Map<String, dynamic>) {
      throw FormatException(
        'GAIA bridge returned invalid conversation payload',
      );
    }

    return GaiaConversationResponse.fromJson(
      Map<String, dynamic>.from(conversation),
    );
  }

  void dispose() {
    _client.close(force: true);
  }
}
