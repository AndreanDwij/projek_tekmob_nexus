import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/loading_indicator.dart';
import 'community_provider.dart';
import 'forum_tab.dart';
import 'event_tab.dart';

class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(communityProvider.notifier).loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Forum'),
            Tab(text: 'Event'),
          ],
        ),
      ),
      body: state.isLoading
          ? const SkeletonLoading()
          : TabBarView(
              controller: _tabController,
              children: const [
                ForumTab(),
                EventTab(),
              ],
            ),
    );
  }
}