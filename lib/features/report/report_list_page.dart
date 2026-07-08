import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../shared/enums.dart';
import 'report_provider.dart';

class ReportListPage extends ConsumerStatefulWidget {
  const ReportListPage({super.key});

  @override
  ConsumerState<ReportListPage> createState() => _ReportListPageState();
}

class _ReportListPageState extends ConsumerState<ReportListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(reportProvider.notifier).loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('Riwayat Laporan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(reportProvider.notifier).loadReports(),
        child: _buildBody(state),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/report/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(ReportListState state) {
    if (state.isLoading) {
      return const SkeletonLoading();
    }

    if (state.error != null) {
      return ErrorStateWidget(
        message: state.error!,
        onRetry: () => ref.read(reportProvider.notifier).loadReports(),
      );
    }

    final reports = state.filteredReports;

    if (reports.isEmpty) {
      return const EmptyStateWidget(
        title: 'Belum Ada Laporan',
        description: 'Anda belum membuat laporan lingkungan. Yuk, laporkan sekarang!',
        icon: Icons.assignment_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return GestureDetector(
          onTap: () => context.push('/report/detail/${report.id}'),
          child: Container(
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
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(report.category),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: const Icon(Icons.report, color: Colors.white, size: 24),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.category.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        report.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildStatusBadge(report.status),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(ReportStatus status) {
    Color color;
    switch (status) {
      case ReportStatus.pending:
        color = AppColors.warning;
        break;
      case ReportStatus.diproses:
        color = AppColors.info;
        break;
      case ReportStatus.selesai:
        color = AppColors.success;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getCategoryColor(ReportCategory category) {
    switch (category) {
      case ReportCategory.sampah:
        return AppColors.earthBrown;
      case ReportCategory.drainase:
        return AppColors.secondary;
      case ReportCategory.jalan:
        return AppColors.textSecondary;
      case ReportCategory.pohon:
        return AppColors.leafGreen;
      case ReportCategory.polusi:
        return AppColors.danger;
      case ReportCategory.lainnya:
        return AppColors.primary;
    }
  }

  void _showFilterSheet() {
    final state = ref.read(reportProvider);
    final selectedCategory = state.selectedCategory;
    final selectedStatus = state.selectedStatus;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Laporan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Semua'),
                  selected: selectedCategory == null,
                  onSelected: (_) {
                    ref.read(reportProvider.notifier).filterByCategory(null);
                    Navigator.pop(ctx);
                  },
                ),
                ...ReportCategory.values.map((cat) => FilterChip(
                      label: Text(cat.label),
                      selected: selectedCategory == cat,
                      onSelected: (_) {
                        ref.read(reportProvider.notifier).filterByCategory(cat);
                        Navigator.pop(ctx);
                      },
                    )),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Status', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Semua'),
                  selected: selectedStatus == null,
                  onSelected: (_) {
                    ref.read(reportProvider.notifier).filterByStatus(null);
                    Navigator.pop(ctx);
                  },
                ),
                ...ReportStatus.values.map((status) => FilterChip(
                      label: Text(status.label),
                      selected: selectedStatus == status,
                      onSelected: (_) {
                        ref.read(reportProvider.notifier).filterByStatus(status);
                        Navigator.pop(ctx);
                      },
                    )),
              ],
            ),
            if (selectedCategory != null || selectedStatus != null) ...[
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: () {
                  ref.read(reportProvider.notifier).clearFilters();
                  Navigator.pop(ctx);
                },
                child: const Text('Hapus Filter'),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}