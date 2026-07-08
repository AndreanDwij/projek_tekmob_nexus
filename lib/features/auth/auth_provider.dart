import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/hive_service.dart';
import 'user_model.dart';

enum AuthState { uninitialized, authenticated, unauthenticated, loading }

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseService _firebaseService = FirebaseService();
  final HiveService _hiveService = HiveService();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  AuthNotifier() : super(AuthState.uninitialized);

  Future<void> checkAuthStatus() async {
    final isLoggedIn = _hiveService.isLoggedIn;
    final firebaseUser = _firebaseService.currentUser;

    if (isLoggedIn && firebaseUser != null) {
      await _loadUserData(firebaseUser.uid);
      state = AuthState.authenticated;
    } else {
      state = AuthState.unauthenticated;
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firebaseService.firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!, doc.id);
        await _hiveService.saveUserData({
          'userId': uid,
          'email': _currentUser!.email,
          'nama': _currentUser!.nama,
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<String?> login(String email, String password) async {
    state = AuthState.loading;
    try {
      final credential = await _firebaseService.auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (!credential.user!.emailVerified) {
        await _firebaseService.logout();
        state = AuthState.unauthenticated;
        return 'Email belum diverifikasi. Silakan cek email Anda.';
      }

      await _loadUserData(credential.user!.uid);
      state = AuthState.authenticated;
      return null;
    } on FirebaseAuthException catch (e) {
      state = AuthState.unauthenticated;
      switch (e.code) {
        case 'user-not-found':
          return 'Email tidak terdaftar';
        case 'wrong-password':
          return 'Password salah';
        case 'invalid-email':
          return 'Email tidak valid';
        case 'user-disabled':
          return 'Akun telah dinonaktifkan';
        default:
          return 'Login gagal. Silakan coba lagi.';
      }
    } catch (e) {
      state = AuthState.unauthenticated;
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  Future<String?> register({
    required String nama,
    required String email,
    required String nomorHp,
    required String password,
  }) async {
    state = AuthState.loading;
    try {
      final credential =
          await _firebaseService.auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user!.sendEmailVerification();

      final user = UserModel(
        uid: credential.user!.uid,
        email: email.trim(),
        nama: nama.trim(),
        nomorHp: nomorHp.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firebaseService.firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .set(user.toMap());

      await _firebaseService.logout();
      state = AuthState.unauthenticated;
      return null;
    } on FirebaseAuthException catch (e) {
      state = AuthState.unauthenticated;
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email sudah terdaftar';
        case 'invalid-email':
          return 'Email tidak valid';
        case 'weak-password':
          return 'Password terlalu lemah';
        default:
          return 'Registrasi gagal. Silakan coba lagi.';
      }
    } catch (e) {
      state = AuthState.unauthenticated;
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  Future<String?> updateProfile(Map<String, dynamic> data) async {
    try {
      final uid = _firebaseService.currentUser?.uid;
      if (uid == null) return 'Pengguna tidak ditemukan';

      data['updatedAt'] = DateTime.now();
      await _firebaseService.firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update(data);

      await _loadUserData(uid);
      return null;
    } catch (e) {
      return 'Gagal memperbarui profil';
    }
  }

  Future<String?> uploadPhoto(String filePath) async {
    try {
      final uid = _firebaseService.currentUser?.uid;
      if (uid == null) return 'Pengguna tidak ditemukan';

      final ref = _firebaseService.storage
          .ref()
          .child('${AppConstants.profileImagesPath}/$uid');

      await ref.putFile(File(filePath));
      final url = await ref.getDownloadURL();

      await updateProfile({'photoUrl': url});
      return null;
    } catch (e) {
      return 'Gagal mengunggah foto';
    }
  }

  Future<void> logout() async {
    await _firebaseService.logout();
    await _hiveService.clearUserData();
    _currentUser = null;
    state = AuthState.unauthenticated;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final currentUserProvider = Provider<UserModel?>((ref) {

  ref.watch(authProvider);
  return ref.read(authProvider.notifier).currentUser;
});