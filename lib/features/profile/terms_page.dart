import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/settings'),
        ),
        title: const Text('Ketentuan Layanan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const Text(
            'Terakhir diperbarui: Juli 2026',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSection(
            title: '1. Penerimaan Ketentuan',
            content:
                'Dengan menggunakan aplikasi EcoLife, Anda dianggap telah membaca, memahami, dan menyetujui seluruh ketentuan layanan ini.',
          ),
          _buildSection(
            title: '2. Akun Pengguna',
            content:
                'Anda bertanggung jawab menjaga kerahasiaan kata sandi akun Anda. Segala aktivitas yang terjadi di akun Anda menjadi tanggung jawab Anda sepenuhnya.',
          ),
          _buildSection(
            title: '3. Laporan Lingkungan',
            content:
                'Laporan yang dikirim harus akurat dan sesuai kondisi nyata di lapangan. Laporan palsu atau menyesatkan dapat mengakibatkan penangguhan akun.',
          ),
          _buildSection(
            title: '4. Eco Point & Reward',
            content:
                'Eco Point diberikan berdasarkan aktivitas sah di aplikasi dan tidak dapat diuangkan. Kami berhak membatalkan poin yang diperoleh dari kecurangan atau manipulasi sistem.',
          ),
          _buildSection(
            title: '5. Event Komunitas',
            content:
                'Partisipasi dalam event komunitas tunduk pada kuota dan jadwal yang ditentukan penyelenggara. Kehadiran fisik dapat diverifikasi oleh panitia event.',
          ),
          _buildSection(
            title: '6. Konten Pengguna',
            content:
                'Anda bertanggung jawab atas foto, deskripsi, dan postingan komunitas yang Anda unggah. Konten yang melanggar hukum atau mengandung SARA akan dihapus.',
          ),
          _buildSection(
            title: '7. Perubahan Ketentuan',
            content:
                'Kami dapat memperbarui ketentuan layanan ini sewaktu-waktu. Perubahan akan diinformasikan melalui aplikasi.',
          ),
          _buildSection(
            title: '8. Kontak',
            content:
                'Untuk pertanyaan terkait ketentuan layanan, hubungi kami di support@ecolife.app.',
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
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
            content,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}