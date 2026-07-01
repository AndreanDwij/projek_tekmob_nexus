import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../shared/enums.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String nama;
  final String? nomorHp;
  final String? photoUrl;
  final UserRole role;
  final int ecoPoint;
  final int totalLaporan;
  final int totalEvent;
  final int totalCarbon;
  final String? alamat;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.nama,
    this.nomorHp,
    this.photoUrl,
    this.role = UserRole.warga,
    this.ecoPoint = 0,
    this.totalLaporan = 0,
    this.totalEvent = 0,
    this.totalCarbon = 0,
    this.alamat,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      nama: map['nama'] ?? '',
      nomorHp: map['nomorHp'],
      photoUrl: map['photoUrl'],
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.warga,
      ),
      ecoPoint: map['ecoPoint'] ?? 0,
      totalLaporan: map['totalLaporan'] ?? 0,
      totalEvent: map['totalEvent'] ?? 0,
      totalCarbon: map['totalCarbon'] ?? 0,
      alamat: map['alamat'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nama': nama,
      'nomorHp': nomorHp,
      'photoUrl': photoUrl,
      'role': role.name,
      'ecoPoint': ecoPoint,
      'totalLaporan': totalLaporan,
      'totalEvent': totalEvent,
      'totalCarbon': totalCarbon,
      'alamat': alamat,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? nama,
    String? nomorHp,
    String? photoUrl,
    UserRole? role,
    int? ecoPoint,
    int? totalLaporan,
    int? totalEvent,
    int? totalCarbon,
    String? alamat,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nama: nama ?? this.nama,
      nomorHp: nomorHp ?? this.nomorHp,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      ecoPoint: ecoPoint ?? this.ecoPoint,
      totalLaporan: totalLaporan ?? this.totalLaporan,
      totalEvent: totalEvent ?? this.totalEvent,
      totalCarbon: totalCarbon ?? this.totalCarbon,
      alamat: alamat ?? this.alamat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        nama,
        nomorHp,
        photoUrl,
        role,
        ecoPoint,
        totalLaporan,
        totalEvent,
        totalCarbon,
        alamat,
        createdAt,
        updatedAt,
      ];
}
