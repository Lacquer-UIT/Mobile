import 'package:dio/dio.dart';
import 'package:lacquer/features/flashcard/dtos/card_dto.dart';
import 'dart:io';
import 'package:lacquer/features/flashcard/dtos/create_tag_dto.dart';
import 'package:lacquer/features/flashcard/dtos/finish_deck_dto.dart';
import 'package:lacquer/features/flashcard/dtos/get_deck_dto.dart';
import 'package:lacquer/features/flashcard/dtos/grouped_decks_dto.dart';
import 'package:lacquer/features/flashcard/dtos/update_deck_dto.dart';
import 'package:lacquer/features/flashcard/dtos/update_tag_dto.dart';

import '../dtos/create_deck_dto.dart';
import 'flashcard_api_client.dart';

class FlashcardRepository {
  final FlashcardApiClient apiClient;

  FlashcardRepository(this.apiClient);

  Future<CreateDeckResponseDto> createDeck({
    required String title,
    required String description,
    required List<String> tags,
    required List<CardDto> cards,
    File? imageFile,
  }) async {
    final deckDto = CreateDeckDto(
      title: title,
      description: description,
      tags: tags,
      cards: cards,
    );

    return apiClient.createDeck(deckDto, imageFile);
  }

  Future<GroupedDecksResponseDto> getDecks() async {
    try {
      final response = await apiClient.getDecks();
      final responseData = response as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw Exception(
          'Failed to load decks: ${responseData['message'] ?? 'Unknown error'}',
        );
      }

      return GroupedDecksResponseDto.fromJson(responseData);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<List<GetDeckDto>> getUserAllDecks() async {
    try {
      final response = await apiClient.getUserAllDecks();
      final responseData = response as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw Exception(
          'Failed to load decks: ${responseData['message'] ?? 'Unknown error'}',
        );
      }

      final decksData = responseData['data']['data'] as List<dynamic>;
      return decksData
          .map(
            (deckJson) => GetDeckDto.fromJson(deckJson as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<List<CreateTagResponseDto>> getTags() async {
    return apiClient.getTags();
  }

  Future<CreateTagResponseDto> createTag({required String name}) async {
    final tagDto = CreateTagDto(name: name);

    return apiClient.createTag(tagDto);
  }

  Future<CreateDeckResponseDto> getDeckById(String deckId) async {
    final response = await apiClient.getDeckById(deckId);
    final responseData = response;
    if (responseData['success'] == true) {
      return CreateDeckResponseDto.fromJson(responseData['data']);
    } else {
      throw Exception(responseData['message'] ?? 'Failed to retrieve deck');
    }
  }

  Future<void> deleteDeck(String deckId) async {
    return apiClient.deleteDeck(deckId);
  }

  Future<CreateDeckResponseDto> updateDeck({
    required String deckId,
    required String title,
    required String description,
    required List<String> tags,
    File? imageFile,
  }) async {
    final deckDto = UpdateDeckDto(
      id: deckId,
      title: title,
      description: description,
      tags: tags,
    );

    return apiClient.updateDeck(deckId, deckDto, imageFile);
  }

  Future<CreateTagResponseDto> updateTag({
    required String tagId,
    required String name,
    String? description,
  }) async {
    final dto = UpdateTagDto(
      id: tagId,
      name: name,
      description: description ?? '',
    );
    return apiClient.updateTag(tagId, dto);
  }

  Future<void> deleteTag(String tagId) async {
    await apiClient.deleteTag(tagId);
  }

  Future<void> deleteCard(String deckId, String cardId) async {
    await apiClient.deleteCard(deckId, cardId);
  }

  Future<void> addCardToDeck({
    required String deckId,
    required String cardId,
  }) async {
    try {
      await apiClient.addCardToDeck(deckId: deckId, cardId: cardId);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response!.data['message'] ?? 'Failed to add card to deck',
        );
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<FinishDeckResponseDto> finishDeck(String deckId) async {
    try {
      final response = await apiClient.finishDeck(deckId);
      return response;
    } catch (e) {
      throw Exception('Failed to finish deck: $e');
    }
  }
}
