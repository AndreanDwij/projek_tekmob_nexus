import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/profile'),
        ),
        title: const Text('Bantuan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildHelpItem(
            icon: Icons.report_problem_outlined,
            title: 'Cara Membuat Laporan',
            description:
                '1. Buka menu Lapor\n2. Pilih kategori\n3. Ambil foto\n4. Tentukan lokasi\n5. Tulis deskripsi\n6. Kirim laporan',
          ),
          _buildHelpItem(
            icon: Icons.emoji_events_outlined,
            title: 'Cara Mendapatkan Eco Point',
            description:
                '• Membuat laporan: 10 poin\n• Laporan diverifikasi: 25 poin\n• Ikut event: 15 poin\n• Hitung karbon: 5 poin',
          ),
          _buildHelpItem(
            icon: Icons.card_giftcard_outlined,
            title: 'Cara Menukar Reward',
            description:
                '1. Buka menu Reward\n2. Pilih reward yang diinginkan\n3. Pastikan poin cukup\n4. Klik Tukar Reward\n5. Reward akan diproses',
          ),
          _buildHelpItem(
            icon: Icons.cloud_outlined,
            title: 'Cara Menghitung Jejak Karbon',
            description:
                '1. Buka menu Jejak Karbon\n2. Pilih jenis transportasi\n3. Masukkan jarak tempuh\n4. Klik Hitung Emisi\n5. Simpan hasilnya',
          ),
          _buildHelpItem(
            icon: Icons.groups_outlined,
            title: 'Cara Bergabung Event',
            description:
                '1. Buka menu Community\n2. Pilih tab Event\n3. Pilih event yang tersedia\n4. Baca detail event\n5. Klik Gabung Event',
          ),
          _buildHelpItem(
            icon: Icons.contact_support_outlined,
            title: 'Hubungi Kami',
            description:
                'Jika ada pertanyaan atau kendala, silakan hubungi kami melalui:\n\nEmail: support@ecolife.app\nInstagram: @ecolife.app',
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: AppElevation.level1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}