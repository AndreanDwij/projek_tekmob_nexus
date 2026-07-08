import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../core/services/firebase_service.dart';
import '../auth/auth_provider.dart';
import 'community_model.dart';

class CommunityState {
  final List<CommunityPostModel> posts;
  final List<EventModel> events;
  final bool isLoading;
  final String? error;

  const CommunityState({
    this.posts = const [],
    this.events = const [],
    this.isLoading = false,
    this.error,
  });

  CommunityState copyWith({
    List<CommunityPostModel>? posts,
    List<EventModel>? events,
    bool? isLoading,
    String? error,
  }) {
    return CommunityState(
      posts: posts ?? this.posts,
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CommunityNotifier extends StateNotifier<CommunityState> {
  final FirebaseService _firebaseService = FirebaseService();
  final Ref _ref;

  CommunityNotifier(this._ref) : super(const CommunityState());

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.wait([_loadPosts(), _loadEvents()]);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat data komunitas');
    }
  }

  Future<void> refreshPosts() async {
    await _loadPosts();
  }

  Future<void> _loadPosts() async {
    final snapshot = await _firebaseService.firestore
        .collection(AppConstants.communityPostsCollection)
        .orderBy('createdAt', descending: true)
        .get();

    final posts = snapshot.docs
        .map((doc) => CommunityPostModel.fromMap(doc.data(), doc.id))
        .toList();

    state = state.copyWith(posts: posts);
  }

  Future<void> _loadEvents() async {
    final snapshot = await _firebaseService.firestore
        .collection(AppConstants.eventsCollection)
        .orderBy('eventDate', descending: false)
        .get();

    final events = snapshot.docs
        .map((doc) => EventModel.fromMap(doc.data(), doc.id))
        .toList();

    state = state.copyWith(events: events);
  }

  List<EventModel> get upcomingEvents =>
      state.events.where((e) => e.isUpcoming).toList();

  List<EventModel> get ongoingEvents =>
      state.events.where((e) => e.isOngoing).toList();

  Future<String?> createPost(String content, {String? imageUrl}) async {
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) return 'Pengguna tidak ditemukan';

      final post = CommunityPostModel(
        id: '',
        userId: user.uid,
        userName: user.nama,
        userPhotoUrl: user.photoUrl,
        content: content,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firebaseService.firestore
          .collection(AppConstants.communityPostsCollection)
          .add(post.toMap());

      await _loadPosts();
      return null;
    } catch (e) {
      return 'Gagal membuat postingan';
    }
  }

  Future<String?> createEvent({
    required String title,
    required String description,
    required String location,
    required double latitude,
    required double longitude,
    required DateTime eventDate,
    required DateTime eventEndDate,
    int maxParticipants = 50,
    String? imageUrl,
  }) async {
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) return 'Pengguna tidak ditemukan';

      final event = EventModel(
        id: '',
        creatorId: user.uid,
        creatorName: user.nama,
        title: title,
        description: description,
        imageUrl: imageUrl,
        location: location,
        latitude: latitude,
        longitude: longitude,
        eventDate: eventDate,
        eventEndDate: eventEndDate,
        maxParticipants: maxParticipants,
        currentParticipants: 0,
        participants: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firebaseService.firestore
          .collection(AppConstants.eventsCollection)
          .add(event.toMap());

      await _loadEvents();
      return null;
    } catch (e) {
      return 'Gagal membuat event';
    }
  }

  Future<String?> joinEvent(String eventId) async {
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) return 'Pengguna tidak ditemukan';

      final eventRef = _firebaseService.firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId);

      final eventDoc = await eventRef.get();
      if (!eventDoc.exists) return 'Event tidak ditemukan';

      final event = EventModel.fromMap(eventDoc.data()!, eventDoc.id);

      if (event.isFull) return 'Event sudah penuh';
      if (event.participants.contains(user.uid)) return 'Anda sudah bergabung';

      await eventRef.update({
        'participants': FieldValue.arrayUnion([user.uid]),
        'currentParticipants': FieldValue.increment(1),
      });

      await _firebaseService.firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({
        'totalEvent': FieldValue.increment(1),
        'ecoPoint': FieldValue.increment(AppConstants.eventJoinPoint),
      });

      await _loadEvents();
      return null;
    } catch (e) {
      return 'Gagal bergabung event';
    }
  }

  Future<String?> likePost(String postId) async {
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) return 'Pengguna tidak ditemukan';

      final postRef = _firebaseService.firestore
          .collection(AppConstants.communityPostsCollection)
          .doc(postId);

      final postDoc = await postRef.get();
      if (!postDoc.exists) return 'Postingan tidak ditemukan';

      final post = CommunityPostModel.fromMap(postDoc.data()!, postDoc.id);

      if (post.likes.contains(user.uid)) {
        await postRef.update({
          'likes': FieldValue.arrayRemove([user.uid]),
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        await postRef.update({
          'likes': FieldValue.arrayUnion([user.uid]),
          'likeCount': FieldValue.increment(1),
        });
      }

      await _loadPosts();
      return null;
    } catch (e) {
      return 'Gagal memberikan like';
    }
  }
}

final communityProvider =
    StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
  return CommunityNotifier(ref);
});

// ===================== COMMENTS =====================

class CommentsState {
  final List<CommentModel> comments;
  final bool isLoading;
  final String? error;

  const CommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.error,
  });

  CommentsState copyWith({
    List<CommentModel>? comments,
    bool? isLoading,
    String? error,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CommentsNotifier extends StateNotifier<CommentsState> {
  final FirebaseService _firebaseService = FirebaseService();
  final Ref _ref;
  final String postId;

  CommentsNotifier(this._ref, this.postId) : super(const CommentsState());

  CollectionReference<Map<String, dynamic>> get _commentsRef =>
      _firebaseService.firestore
          .collection(AppConstants.communityPostsCollection)
          .doc(postId)
          .collection('comments');

  Future<void> loadComments() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final snapshot =
          await _commentsRef.orderBy('createdAt', descending: false).get();

      final comments = snapshot.docs
          .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
          .toList();

      state = state.copyWith(comments: comments, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat komentar');
    }
  }

  Future<String?> addComment(String content) async {
    if (content.trim().isEmpty) return 'Komentar tidak boleh kosong';
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) return 'Pengguna tidak ditemukan';

      final comment = CommentModel(
        id: '',
        postId: postId,
        userId: user.uid,
        userName: user.nama,
        userPhotoUrl: user.photoUrl,
        content: content.trim(),
        createdAt: DateTime.now(),
      );

      await _commentsRef.add(comment.toMap());

      await _firebaseService.firestore
          .collection(AppConstants.communityPostsCollection)
          .doc(postId)
          .update({'commentCount': FieldValue.increment(1)});

      await loadComments();
      await _ref.read(communityProvider.notifier).refreshPosts();
      return null;
    } catch (e) {
      return 'Gagal menambahkan komentar';
    }
  }
}

final commentsProvider =
    StateNotifierProvider.family<CommentsNotifier, CommentsState, String>(
  (ref, postId) => CommentsNotifier(ref, postId),
);