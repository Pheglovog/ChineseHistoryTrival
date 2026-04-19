import 'package:dio/dio.dart';

class AiMatchingRequest {
  final String ancientName;
  final String? alias;
  final String? context;

  AiMatchingRequest({
    required this.ancientName,
    this.alias,
    this.context,
  });

  Map<String, dynamic> toJson() => {
        'ancient_name': ancientName,
        if (alias != null) 'alias': alias,
        if (context != null) 'context': context,
      };
}

class AiMatchingResult {
  final String modernName;
  final String? province;
  final double latitude;
  final double longitude;
  final double confidence;
  final String? explanation;

  AiMatchingResult({
    required this.modernName,
    this.province,
    required this.latitude,
    required this.longitude,
    required this.confidence,
    this.explanation,
  });

  factory AiMatchingResult.fromJson(Map<String, dynamic> json) =>
      AiMatchingResult(
        modernName: json['modern_name'] as String,
        province: json['province'] as String?,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        confidence: (json['confidence'] as num).toDouble(),
        explanation: json['explanation'] as String?,
      );

  bool get isCoordinatesValid =>
      latitude >= 18 &&
      latitude <= 54 &&
      longitude >= 73 &&
      longitude <= 135;
}

class AiMatchingService {
  final Dio _dio;
  final String baseUrl;

  AiMatchingService({
    required this.baseUrl,
    Dio? dio,
  }) : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 30),
            ));

  Future<AiMatchingResult?> matchLocation(AiMatchingRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v1/matching/ancient-to-modern',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final result = AiMatchingResult.fromJson(
          response.data is Map<String, dynamic>
              ? response.data
              : response.data['data'] as Map<String, dynamic>,
        );

        // Validate coordinates are within China
        if (!result.isCoordinatesValid) return null;

        return result;
      }
      return null;
    } on DioException {
      return null;
    }
  }
}
