import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../shared/enums.dart';
import 'carbon_provider.dart';

class CarbonFootprintPage extends ConsumerStatefulWidget {
  const CarbonFootprintPage({super.key});

  @override
  ConsumerState<CarbonFootprintPage> createState() => _CarbonFootprintPageState();
}

class _CarbonFootprintPageState extends ConsumerState<CarbonFootprintPage> {
  TransportationType? _selectedTransport;
  final _distanceController = TextEditingController();
  bool _isCalculating = false;
  double? _result;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(carbonProvider.notifier).loadFootprints();
    });
  }

  @override
  void dispose() {
    _distanceController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_selectedTransport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jenis transportasi')),
      );
      return;
    }
    final distance = double.tryParse(_distanceController.text);
    if (distance == null || distance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jarak yang valid')),
      );
      return;
    }

    final emission = ref
        .read(carbonProvider.notifier)
        .calculateEmission(_selectedTransport!, distance);
    setState(() => _result = emission);
  }

  Future<void> _save() async {
    if (_selectedTransport == null || _result == null) return;

    setState(() => _isCalculating = true);

    final error = await ref.read(carbonProvider.notifier).saveFootprint(
          transportationType: _selectedTransport!,
          distance: double.parse(_distanceController.text),
        );

    setState(() => _isCalculating = false);

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(carbonProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('Jejak Karbon'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalculatorSection(),
            const SizedBox(height: AppSpacing.xl),
            if (state.totalEmission > 0) ...[
              _buildStatsCard(state),
              const SizedBox(height: AppSpacing.xl),
              _buildChart(state),
            ] else if (!state.isLoading) ...[
              const EmptyStateWidget(
                title: 'Belum Ada Data',
                description: 'Mulai hitung jejak karbon Anda!',
                icon: Icons.cloud_outlined,
              ),
            ],
            if (state.isLoading) const LoadingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
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
          const Text(
            'Hitung Jejak Karbon',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Pilih Transportasi', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TransportationType.values.map((type) {
              final isSelected = _selectedTransport == type;
              return ChoiceChip(
                label: Text(type.label),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedTransport = selected ? type : null);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          CustomTextField(
            controller: _distanceController,
            label: 'Jarak (km)',
            hint: 'Masukkan jarak tempuh',
            prefixIcon: Icons.straighten,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
          CustomButton(
            label: 'Hitung Emisi',
            onPressed: _calculate,
          ),
          if (_result != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppRadius.large),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Emisi Karbon',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_result!.toStringAsFixed(2)} kg CO₂',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  CustomButton(
                    label: 'Simpan',
                    onPressed: _save,
                    isOutlined: true,
                    isLoading: _isCalculating,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsCard(CarbonState state) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.leafGreen.withOpacity(0.8), AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
      ),
      child: Column(
        children: [
          const Text(
            'Total Emisi',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '${state.totalEmission.toStringAsFixed(1)} kg CO₂',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${state.footprints.length} kali perhitungan',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(CarbonState state) {
    final emissionsByType = ref.read(carbonProvider.notifier).getEmissionsByType();
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.warning,
      AppColors.danger,
      AppColors.info,
      AppColors.leafGreen,
      AppColors.earthBrown,
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
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
          const Text(
            'Grafik Emisi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: emissionsByType.entries.toList().asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  return PieChartSectionData(
                    value: e.value,
                    title: '${e.value.toStringAsFixed(1)}',
                    color: colors[i % colors.length],
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...emissionsByType.entries.toList().asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(e.key, style: const TextStyle(fontSize: 13))),
                  Text(
                    '${e.value.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}