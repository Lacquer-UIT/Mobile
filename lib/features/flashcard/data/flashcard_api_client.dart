import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:lacquer/features/flashcard/dtos/finish_deck_dto.dart';
import 'package:lacquer/features/flashcard/dtos/update_deck_dto.dart';
import 'package:lacquer/features/flashcard/dtos/update_tag_dto.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:lacquer/features/flashcard/dtos/create_tag_dto.dart';
import '../dtos/create_deck_dto.dart';
import 'package:lacquer/features/auth/data/auth_local_data_source.dart';

class FlashcardApiClient {
  FlashcardApiClient(this.dio, this.authLocalDataSource);

  final Dio dio;
  final AuthLocalDataSource authLocalDataSource;

  Future<CreateDeckResponseDto> createDeck(
    CreateDeckDto deckDto,
    File? imageFile,
  ) async {
    try {
      final token = await authLocalDataSource.getToken();

      final formData = FormData.fromMap({
        'title': deckDto.title,
        'description': deckDto.description,
        'tags': deckDto.tags,
        'cards': deckDto.cards,
      });

      if (imageFile != null) {
        if (!await imageFile.exists()) {
          throw Exception('Image file does not exist');
        }

        final fileName = imageFile.path.split('/').last;
        final mimeType = lookupMimeType(imageFile.path);

        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: fileName,
              contentType: mimeType != null ? MediaType.parse(mimeType) : null,
            ),
          ),
        );
      }

      final options = Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
      final response = await dio.post(
        '/deck',
        data: formData,
        options: options,
      );

      return CreateDeckResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<dynamic> getDecks() async {
    try {
      final token = await authLocalDataSource.getToken();

      final options = Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      final response = await dio.get('/deck/tag', options: options);

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw Exception(responseData['message'] ?? 'Failed to load decks');
      }

      return responseData;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<dynamic> getUserAllDecks() async {
    try {
      final token = await authLocalDataSource.getToken();
      final options = Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
      final response = await dio.get('/deck', options: options);

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw Exception(responseData['message'] ?? 'Failed to load decks');
      }

      return responseData;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<Map<String, dynamic>> getDeckById(String deckId) async {
    try {
      final token = await authLocalDataSource.getToken();

      final options = Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      final response = await dio.get('/deck/$deckId', options: options);

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<List<CreateTagResponseDto>> getTags() async {
    try {
      final token = await authLocalDataSource.getToken();

      final options = Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      final response = await dio.get('/tag', options: options);

      final responseData = response.data as Map<String, dynamic>;
      final tagData = responseData['data'] as Map<String, dynamic>;
      final tagList = tagData['data'] as List;

      return tagList
          .map((json) => CreateTagResponseDto.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<CreateTagResponseDto> createTag(CreateTagDto tagDto) async {
    try {
      final token = await authLocalDataSource.getToken();

      final options = Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      final response = await dio.post(
        '/tag',
        data: tagDto.toJson(),
        options: options,
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw Exception(
          'Failed to create tag: ${responseData['message'] ?? 'Unknown error'}',
        );
      }

      final tagData = responseData['data'] as Map<String, dynamic>?;
      if (tagData == null) {
        throw Exception('Tag data is missing in API response');
      }

      return CreateTagResponseDto.fromJson(tagData);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<CreateTagResponseDto> updateTag(
    String tagId,
    UpdateTagDto tagDto,
  ) async {
    try {
      final token = await authLocalDataSource.getToken();
      final options = Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
      final response = await dio.put(
        '/tag/$tagId',
        data: tagDto.toJson(),
        options: options,
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw Exception(responseData['message'] ?? 'Failed to update tag');
      }

      final tagData = responseData['data'] as Map<String, dynamic>?;
      if (tagData == null) {
        throw Exception('Tag data is missing in API response');
      }

      return CreateTagResponseDto.fromJson(tagData);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to update tag');
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<FinishDeckResponseDto> finishDeck(String deckId) async {
    try {
      final token = await authLocalDataSource.getToken();
      final options = Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      final response = await dio.put('/deck/$deckId/finish', options: options);

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw Exception(responseData['message'] ?? 'Failed to finish deck');
      }

      return FinishDeckResponseDto.fromJson(responseData);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to finish deck');
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<void> deleteTag(String tagId) async {
    try {
      final token = await authLocalDataSource.getToken();
      final options = Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
      await dio.delete('/tag/$tagId', options: options);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<void> deleteCard(String deckId, String cardId) async {
    try {
      final token = await authLocalDataSource.getToken();
      final options = Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
      await dio.delete('/deck/$deckId/cards/$cardId', options: options);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<void> deleteDeck(String deckId) async {
    try {
      final token = await authLocalDataSource.getToken();

      final options = Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      await dio.delete('/deck/$deckId', options: options);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<CreateDeckResponseDto> updateDeck(
    String deckId,
    UpdateDeckDto deckDto,
    File? imageFile,
  ) async {
    try {
      final token = await authLocalDataSource.getToken();

      final formData = FormData.fromMap({
        'title': deckDto.title,
        'description': deckDto.description,
        'tags': deckDto.tags,
      });

      if (imageFile != null) {
        if (!await imageFile.exists()) {
          throw Exception('Image file does not exist');
        }

        final fileName = imageFile.path.split('/').last;
        final mimeType = lookupMimeType(imageFile.path);

        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: fileName,
              contentType: mimeType != null ? MediaType.parse(mimeType) : null,
            ),
          ),
        );
      }

      final options = Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      final response = await dio.put(
        '/deck/$deckId',
        data: formData,
        options: options,
      );

      return CreateDeckResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<void> addCardToDeck({
    required String deckId,
    required String cardId,
  }) async {
    final token = await authLocalDataSource.getToken();

    final options = Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );

    final response = await dio.post(
      '/deck/$deckId/cards',
      data: {'cardId': cardId},
      options: options,
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to add card to deck');
    }
  }
}
