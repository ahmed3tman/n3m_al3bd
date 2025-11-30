import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n3m_al3bd/features/quran/model/quran_model.dart';
import 'quran_state.dart';

class QuranCubit extends Cubit<QuranState> {
  QuranCubit() : super(QuranInitial());

  Future<void> loadQuran() async {
    emit(QuranLoading());
    try {
      final surahs = await loadQuranData();
      emit(QuranLoaded(surahs));
    } catch (e) {
      emit(QuranError(e.toString()));
    }
  }
}
