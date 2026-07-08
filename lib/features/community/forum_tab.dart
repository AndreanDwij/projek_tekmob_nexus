import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../auth/auth_provider.dart';
import 'community_provider.dart';

class ForumTab extends ConsumerStatefulWidget {
  const ForumTab({super.key});

  @override
  ConsumerState<ForumTab> createState() => _ForumTabState();
}

class _ForumTabState extends ConsumerState<ForumTab> {
  final _postController = TextEditingController();

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  void _showCreatePostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.extraLarge)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buat Postingan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _postController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Tulis sesuatu...'),
            ),
            const SizedBox(height: AppSpacing.md),
            CustomButton(
              label: 'Posting',
              onPressed: () async {
                if (_postController.text.trim().isEmpty) return;
                final error = await ref
                    .read(communityProvider.notifier)
                    .createPost(_postController.text.trim());
                if (!ctx.mounted) return;
                if (error == null) {
                  _postController.clear();
                  Navigator.pop(ctx);
                } else {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(error)));
                }
              },
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _showCommentsSheet(String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.extraLarge)),
      ),
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: _CommentsSheet(postId: postId),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communityProvider);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => ref.read(communityProvider.notifier).loadData(),
          child: state.posts.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 120),
                    EmptyStateWidget(
                      title: 'Belum Ada Postingan',
                      description: 'Jadilah yang pertama berbagi di forum!',
                      icon: Icons.forum_outlined,
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.md, AppSpacing.md, 88),
                  itemCount: state.posts.length,
                  itemBuilder: (context, index) {
                    final post = state.posts[index];
                    final currentUser = ref.read(currentUserProvider);
                    final isLiked =
                        currentUser != null && post.likes.contains(currentUser.uid);

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.large),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: AppElevation.level1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: post.userPhotoUrl != null
                                    ? CachedNetworkImageProvider(post.userPhotoUrl!)
                                    : null,
                                child: post.userPhotoUrl == null
                                    ? Text(
                                        post.userName.isNotEmpty
                                            ? post.userName[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(color: Colors.white),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.userName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      _formatDate(post.createdAt),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (post.content.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(post.content),
                          ],
                          if (post.imageUrl != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.medium),
                              child: CachedNetworkImage(
                                imageUrl: post.imageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    ref.read(communityProvider.notifier).likePost(post.id),
                                child: Row(
                                  children: [
                                    Icon(
                                      isLiked ? Icons.favorite : Icons.favorite_border,
                                      size: 20,
                                      color:
                                          isLiked ? AppColors.danger : AppColors.textHint,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${post.likeCount}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              GestureDetector(
                                onTap: () => _showCommentsSheet(post.id),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.chat_bubble_outline,
                                      size: 20,
                                      color: AppColors.textHint,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${post.commentCount}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        Positioned(
          right: AppSpacing.md,
          bottom: AppSpacing.md,
          child: FloatingActionButton(
            heroTag: 'forum_fab',
            onPressed: _showCreatePostSheet,
            tooltip: 'Buat Postingan',
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class _CommentsSheet extends ConsumerStatefulWidget {
  final String postId;
  const _CommentsSheet({required this.postId});

  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
  final _commentController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(commentsProvider(widget.postId).notifier).loadComments();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _commentController.text;
    if (text.trim().isEmpty) return;

    setState(() => _isSending = true);
    _commentController.clear();

    final error =
        await ref.read(commentsProvider(widget.postId).notifier).addComment(text);

    if (!mounted) return;
    setState(() => _isSending = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentsProvider(widget.postId));

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Komentar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                state.error!,
                style: const TextStyle(color: AppColors.danger, fontSize: 12),
              ),
            ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.comments.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada komentar. Jadi yang pertama!',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: state.comments.length,
                        itemBuilder: (context, index) {
                          final comment = state.comments[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage: comment.userPhotoUrl != null
                                      ? CachedNetworkImageProvider(comment.userPhotoUrl!)
                                      : null,
                                  child: comment.userPhotoUrl == null
                                      ? Text(
                                          comment.userName.isNotEmpty
                                              ? comment.userName[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comment.userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(comment.content, style: const TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(hintText: 'Tulis komentar...'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _isSending
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send, color: AppColors.primary),
                        onPressed: _send,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}