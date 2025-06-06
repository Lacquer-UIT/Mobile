import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacquer/features/quiz/bloc/quiz_event.dart';
import 'package:lacquer/features/quiz/bloc/quiz_state.dart';
import 'package:lacquer/features/quiz/data/quiz_repository.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc(this.quizRepository) : super(QuizStateInitial()) {
    on<QuizEventStarted>(_onStarted);
    on<QuizEventLoadQuestions>(_onLoadQuestions);
    on<QuizEventBack>(_onBack);
  }

  final QuizRepository quizRepository;

  void _onStarted(QuizEventStarted event, Emitter<QuizState> emit) {
    emit(QuizStateInitial());
  }

  Future<void> _onLoadQuestions(
    QuizEventLoadQuestions event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizStateLoading());
    try {
      List<Question> questions = [];
      for (var i = 0; i < event.numberOfQuestions; i++) {
        final optionResults = await quizRepository.getRandomWord(
          event.numverOfOptions,
          event.difficulty,
        );
        if (optionResults.isNotEmpty && !optionResults.containsKey('error')) {
          final options = optionResults.keys.toList();
          final correctAnswer = optionResults.entries.firstWhere(
            (entry) => entry.value != "",
            orElse: () => optionResults.entries.first,
          );
          final definition = correctAnswer.value;
          final answer = correctAnswer.key;
          options.shuffle();
          questions.add(
            Question(definition: definition, answer: answer, options: options),
          );
        } else {
          emit(
            QuizStateFailure(
              "Error fetching words: ${optionResults.containsKey('error') ? optionResults.values : "Empty results"}",
            ),
          );
          return;
        }
      }
      emit(
        QuizStateSuccess(count: event.numberOfQuestions, questions: questions),
      );
    } catch (e) {
      emit(QuizStateFailure("BLoC error: $e"));
      return;
    }
  }

  void _onBack(QuizEventBack event, Emitter<QuizState> emit) {
    emit(QuizStateInitial());
  }
}
