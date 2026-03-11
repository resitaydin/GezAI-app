import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';

import '../models/llm_route_output.dart';

/// System prompt for Turkish route generation constrained to Uskudar
const _systemPrompt = '''
Sen GezAI için bir seyahat rotası planlayıcısısın. Kullanıcının isteğine göre Üsküdar ilçesinde yürüyüş/araç rotaları oluşturuyorsun.

KURALLAR:
1. SADECE Üsküdar ilçesindeki yerleri öner (İstanbul, Türkiye)
2. Tüm metin çıktıları Türkçe olmalı (title_en hariç)
3. Her rota en az 2, en fazla 10 yer içermeli
4. Yerler gerçek ve var olan mekanlar olmalı
5. Kategoriler şunlardan seçilmeli: mosque, museum, park, restaurant, cafe, attraction, historical, poi, other
6. mood_tags örnekleri: cultural, spiritual, relaxing, romantic, family, adventure, food, nature, historical
7. best_time değerleri: morning, afternoon, evening, anytime
8. transport_type değerleri: walking, driving, transit

ÜSKÜDAR'DAKİ POPÜLER YERLER (öncelikli olarak bunlardan seç):
- Kız Kulesi (Maiden's Tower)
- Mihrimah Sultan Camii
- Şemsi Paşa Camii (Kuşkonmaz Camii)
- Çamlıca Tepesi
- Çamlıca Camii
- Fethi Paşa Korusu
- Beylerbeyi Sarayı
- Sakıp Sabancı Müzesi
- Nakkaştepe Millet Bahçesi
- Altunizade Parkı
- Validebağ Korusu
- Fıstıkağacı Parkı
- Salacak Sahili
- Kuzguncuk Mahallesi
- Yeni Valide Camii
- Atik Valide Camii
- Rum Mehmet Paşa Camii
- Şakirin Camii

Her yer için gerçekçi ziyaret süreleri ver (camiler: 20-45 dk, müzeler: 60-120 dk, parklar: 30-60 dk, kafeler: 30-45 dk).
''';

/// Service for generating routes using Firebase AI Logic (Gemini)
class FirebaseAIService {
  GenerativeModel? _model;
  GenerativeModel? _textModel;
  static const modelName = 'gemini-2.5-flash';

  /// Lazy initialization of route model
  GenerativeModel get _routeModel {
    _model ??= FirebaseAI.googleAI().generativeModel(
      model: modelName,
      systemInstruction: Content.system(_systemPrompt),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: _routeSchema,
        temperature: 0.7,
        maxOutputTokens: 8192,
      ),
    );
    return _model!;
  }

  /// Lazy initialization of text model
  GenerativeModel get _aboutModel {
    _textModel ??= FirebaseAI.googleAI().generativeModel(
      model: modelName,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 1024,
      ),
    );
    return _textModel!;
  }

  /// JSON Schema for structured output matching backend LLMRouteOutput
  static final _routeSchema = Schema.object(
    properties: {
      'title': Schema.string(description: 'Rota başlığı (Türkçe)'),
      'title_en': Schema.string(description: 'Route title (English)'),
      'description': Schema.string(description: 'Rota açıklaması (Türkçe)'),
      'region': Schema.array(
        items: Schema.string(),
        description: 'Kapsanan bölgeler',
      ),
      'duration_hours': Schema.number(description: 'Toplam süre (saat)'),
      'transport_type': Schema.enumString(
        enumValues: ['walking', 'driving', 'transit'],
        description: 'Ulaşım tipi',
      ),
      'categories': Schema.array(
        items: Schema.string(),
        description: 'Yer kategorileri',
      ),
      'mood_tags': Schema.array(
        items: Schema.string(),
        description: 'Rota atmosferi etiketleri',
      ),
      'best_time': Schema.enumString(
        enumValues: ['morning', 'afternoon', 'evening', 'anytime'],
        description: 'En uygun zaman',
      ),
      'places': Schema.array(
        items: Schema.object(
          properties: {
            'name': Schema.string(description: 'Yer adı (Türkçe)'),
            'region': Schema.string(description: 'Bölge'),
            'order': Schema.integer(description: 'Sıra numarası'),
            'duration_minutes': Schema.integer(
              description: 'Ziyaret süresi (dakika)',
            ),
            'notes': Schema.string(
              description: 'Yer hakkında notlar (Türkçe)',
            ),
            'travel_to_next': Schema.object(
              properties: {
                'distance_km': Schema.number(description: 'Mesafe (km)'),
                'duration_minutes': Schema.integer(
                  description: 'Yolculuk süresi (dakika)',
                ),
              },
              description: 'Sonraki yere ulaşım bilgisi',
            ),
          },
          optionalProperties: ['travel_to_next'],
        ),
        description: 'Rotadaki yerler',
      ),
    },
  );

  FirebaseAIService();

  /// Generate a route from natural language prompt
  ///
  /// [prompt] User's natural language request (Turkish)
  /// [transportType] Preferred transport mode: walking, driving, transit
  /// [maxPlaces] Maximum number of places in the route (default 5)
  ///
  /// Returns tuple of (LLMRouteOutput, generationTimeMs)
  Future<(LLMRouteOutput, int)> generateRoute(
    String prompt,
    String transportType, {
    int maxPlaces = 5,
  }) async {
    final transportText = _getTransportText(transportType);
    final fullPrompt = '''
Kullanıcı isteği: $prompt

Ulaşım tercihi: $transportText

ÖNEMLİ: Rota en fazla $maxPlaces yer içermelidir.

Lütfen yukarıdaki isteğe uygun bir Üsküdar rotası oluştur.
''';

    final stopwatch = Stopwatch()..start();

    final response = await _routeModel.generateContent([Content.text(fullPrompt)]);

    stopwatch.stop();
    final generationTimeMs = stopwatch.elapsedMilliseconds;

    final responseText = response.text;
    if (responseText == null || responseText.isEmpty) {
      throw FirebaseAIException('Empty response from Gemini');
    }

    // Parse JSON with better error handling
    try {
      final jsonData = jsonDecode(responseText);
      final routeOutput = LLMRouteOutput.fromJson(jsonData);
      return (routeOutput, generationTimeMs);
    } on FormatException catch (e) {
      // Log the problematic response for debugging
      // print('=== JSON PARSING ERROR ===');
      // print('Error: $e');
      // print('Response length: ${responseText.length} chars');
      // print('Full response text:');
      // print(responseText);
      // print('=== END RESPONSE ===');
      throw FirebaseAIException(
        'Failed to parse route response: ${e.message}. Response length: ${responseText.length} chars.',
      );
    } catch (e) {
      // print('=== UNEXPECTED ERROR PARSING ROUTE ===');
      // print('Error type: ${e.runtimeType}');
      // print('Error: $e');
      // print('Response length: ${responseText.length} chars');
      // print('Full response text:');
      // print(responseText);
      // print('=== END ===');
      rethrow;
    }
  }

  /// Map transport type to Turkish text for prompt
  String _getTransportText(String type) {
    switch (type) {
      case 'walking':
        return 'yürüyerek';
      case 'driving':
        return 'araçla';
      case 'transit':
        return 'toplu taşıma ile';
      default:
        return 'yürüyerek';
    }
  }

  /// Generate an 'about' description for a place
  ///
  /// [name] Place name in Turkish (e.g., "Kız Kulesi")
  /// [region] Region name (e.g., "Üsküdar")
  ///
  /// Returns generated about text in Turkish (3-5 sentences)
  Future<String> generatePlaceAbout(String name, String region) async {
    final prompt = '''
Sen bir Türkiye seyahat rehberisin. Aşağıdaki yer hakkında kısa ve bilgilendirici bir tanıtım yaz.

Yer: $name
Bölge: $region, İstanbul

Kurallar:
- Türkçe yaz
- 3-5 cümle olsun
- Tarihi, kültürel veya turistik önemini vurgula
- Ziyaretçiler için faydalı bilgi ver
- Sadece tanıtım metnini yaz, başlık veya ek açıklama ekleme
''';

    final response = await _aboutModel.generateContent([Content.text(prompt)]);

    if (response.text == null || response.text!.isEmpty) {
      throw FirebaseAIException('Empty response from Gemini for place about');
    }

    return response.text!.trim();
  }
}

/// Exception for Firebase AI service errors
class FirebaseAIException implements Exception {
  final String message;
  FirebaseAIException(this.message);

  @override
  String toString() => 'FirebaseAIException: $message';
}
