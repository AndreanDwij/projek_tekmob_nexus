import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../shared/enums.dart';

class ReportModel extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final ReportCategory category;
  final ReportStatus status;
  final String description;
  final List<String> imageUrls;
  final double latitude;
  final double longitude;
  final String? address;
  final String? tanggapan;
  final int ecoPoint;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReportModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.category,
    required this.status,
    required this.description,
    required this.imageUrls,
    required this.latitude,
    required this.longitude,
    this.address,
    this.tanggapan,
    this.ecoPoint = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map, String id) {
    return ReportModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      category: ReportCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => ReportCategory.lainnya,
      ),
      status: ReportStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => ReportStatus.pending,
      ),
      description: map['description'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      address: map['address'],
      tanggapan: map['tanggapan'],
      ecoPoint: map['ecoPoint'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'category': category.name,
      'status': status.name,
      'description': description,
      'imageUrls': imageUrls,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'tanggapan': tanggapan,
      'ecoPoint': ecoPoint,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  ReportModel copyWith({
    String? id,
    String? userId,
    String? userName,
    ReportCategory? category,
    ReportStatus? status,
    String? description,
    List<String>? imageUrls,
    double? latitude,
    double? longitude,
    String? address,
    String? tanggapan,
    int? ecoPoint,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      category: category ?? this.category,
      status: status ?? this.status,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      tanggapan: tanggapan ?? this.tanggapan,
      ecoPoint: ecoPoint ?? this.ecoPoint,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        category,
        status,
        description,
        imageUrls,
        latitude,
        longitude,
        address,
        tanggapan,
        ecoPoint,
        createdAt,
        updatedAt,
      ];
}
