import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repository/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _userRepository;

  AuthCubit(this._userRepository) : super(AuthInitial());

  Future<void> getSignIn(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await _userRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(LoggedIn(userCredential: response));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String date,
    required String province,
    required String birthplace,
    required String numberplate,
  }) async {
    emit(AuthLoading());
    try {
      final userCredential = await _userRepository.signUp(
        name: name,
        email: email,
        password: password,
        date: date,
        province: province,
        birthplace: birthplace,
        numberplate: numberplate,
      );
      emit(SignedUp(userCredential: userCredential));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        emit(AuthError('Bu e-posta adresi zaten kullanılıyor.'));
      } else {
        emit(AuthError(e.message ?? 'Kayıt başarısız.'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  Future<void> signInWithGitHub(String accessToken) async {
    emit(AuthLoading());
    try {
      final credential = GithubAuthProvider.credential(accessToken);
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      emit(LoggedIn(userCredential: userCredential));
    } catch (e) {
      emit(AuthError("GitHub ile giriş başarısız: $e"));
    }
  }

  Future<void> getsignOut() async {
    emit(AuthLoading());
    try {
      await _userRepository.loggedOut();
      emit(LoggedOut());
    } catch (e) {
      emit(AuthError("hata oluştu: $e"));
    }
  }
}
