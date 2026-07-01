import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class RewardModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final int pointRequired;
  final int stock;
  final int totalRedeemed;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RewardModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.pointRequired,
    this.stock = 0,
    this.totalRedeemed = 0,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOutOfStock => stock <= 0;

  factory RewardModel.fromMap(Map<String, dynamic> map, String id) {
    return RewardModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      pointRequired: map['pointRequired'] ?? 0,
      stock: map['stock'] ?? 0,
      totalRedeemed: map['totalRedeemed'] ?? 0,
      isAvailable: map['isAvailable'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'pointRequired': pointRequired,
      'stock': stock,
      'totalRedeemed': totalRedeemed,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  RewardModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? pointRequired,
    int? stock,
    int? totalRedeemed,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RewardModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      pointRequired: pointRequired ?? this.pointRequired,
      stock: stock ?? this.stock,
      totalRedeemed: totalRedeemed ?? this.totalRedeemed,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        pointRequired,
        stock,
        totalRedeemed,
        isAvailable,
        createdAt,
        updatedAt,
      ];
}

class RedemptionModel extends Equatable {
  final String id;
  final String userId;
  final String rewardId;
  final String rewardName;
  final int pointUsed;
  final String status;
  final String? qrCode;
  final DateTime createdAt;

  const RedemptionModel({
    required this.id,
    required this.userId,
    required this.rewardId,
    required this.rewardName,
    required this.pointUsed,
    this.status = 'pending',
    this.qrCode,
    required this.createdAt,
  });

  factory RedemptionModel.fromMap(Map<String, dynamic> map, String id) {
    return RedemptionModel(
      id: id,
      userId: map['userId'] ?? '',
      rewardId: map['rewardId'] ?? '',
      rewardName: map['rewardName'] ?? '',
      pointUsed: map['pointUsed'] ?? 0,
      status: map['status'] ?? 'pending',
      qrCode: map['qrCode'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'rewardId': rewardId,
      'rewardName': rewardName,
      'pointUsed': pointUsed,
      'status': status,
      'qrCode': qrCode,
      'createdAt': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        rewardId,
        rewardName,
        pointUsed,
        status,
        qrCode,
        createdAt,
      ];
}
