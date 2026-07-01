import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class EventModel extends Equatable {
  final String id;
  final String creatorId;
  final String creatorName;
  final String title;
  final String description;
  final String? imageUrl;
  final String location;
  final double latitude;
  final double longitude;
  final DateTime eventDate;
  final DateTime eventEndDate;
  final int maxParticipants;
  final int currentParticipants;
  final List<String> participants;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EventModel({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.eventDate,
    required this.eventEndDate,
    this.maxParticipants = 50,
    this.currentParticipants = 0,
    this.participants = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isFull => currentParticipants >= maxParticipants;
  bool get isOngoing => eventDate.isBefore(DateTime.now()) && eventEndDate.isAfter(DateTime.now());
  bool get isPast => eventEndDate.isBefore(DateTime.now());
  bool get isUpcoming => eventDate.isAfter(DateTime.now());

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      creatorId: map['creatorId'] ?? '',
      creatorName: map['creatorName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      location: map['location'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      eventDate: (map['eventDate'] as Timestamp).toDate(),
      eventEndDate: (map['eventEndDate'] as Timestamp).toDate(),
      maxParticipants: map['maxParticipants'] ?? 50,
      currentParticipants: map['currentParticipants'] ?? 0,
      participants: List<String>.from(map['participants'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'creatorId': creatorId,
      'creatorName': creatorName,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'eventDate': eventDate,
      'eventEndDate': eventEndDate,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'participants': participants,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  EventModel copyWith({
    String? id,
    String? creatorId,
    String? creatorName,
    String? title,
    String? description,
    String? imageUrl,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? eventDate,
    DateTime? eventEndDate,
    int? maxParticipants,
    int? currentParticipants,
    List<String>? participants,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      eventDate: eventDate ?? this.eventDate,
      eventEndDate: eventEndDate ?? this.eventEndDate,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      participants: participants ?? this.participants,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        creatorId,
        creatorName,
        title,
        description,
        imageUrl,
        location,
        latitude,
        longitude,
        eventDate,
        eventEndDate,
        maxParticipants,
        currentParticipants,
        participants,
        createdAt,
        updatedAt,
      ];
}

class CommunityPostModel extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String content;
  final String? imageUrl;
  final int likeCount;
  final List<String> likes;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CommunityPostModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.content,
    this.imageUrl,
    this.likeCount = 0,
    this.likes = const [],
    this.commentCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommunityPostModel.fromMap(Map<String, dynamic> map, String id) {
    return CommunityPostModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      likeCount: map['likeCount'] ?? 0,
      likes: List<String>.from(map['likes'] ?? []),
      commentCount: map['commentCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'imageUrl': imageUrl,
      'likeCount': likeCount,
      'likes': likes,
      'commentCount': commentCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userPhotoUrl,
        content,
        imageUrl,
        likeCount,
        likes,
        commentCount,
        createdAt,
        updatedAt,
      ];
}
