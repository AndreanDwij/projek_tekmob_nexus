import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/settings'),
        ),
        title: const Text('Kebijakan Privasi'),
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
            title: '1. Data yang Kami Kumpulkan',
            content:
                'Kami mengumpulkan data akun (nama, email, nomor HP), foto profil, lokasi laporan lingkungan, dan aktivitas Anda di dalam aplikasi (laporan, event, penukaran reward, jejak karbon).',
          ),
          _buildSection(
            title: '2. Penggunaan Data',
            content:
                'Data digunakan untuk menampilkan laporan di peta, menghitung Eco Point, memverifikasi laporan, mengelola event komunitas, dan meningkatkan layanan aplikasi EcoLife.',
          ),
          _buildSection(
            title: '3. Lokasi',
            content:
                'Akses lokasi digunakan hanya untuk menandai posisi laporan lingkungan dan menampilkan laporan terdekat di peta. Anda dapat menonaktifkan akses lokasi kapan saja melalui menu Pengaturan.',
          ),
          _buildSection(
            title: '4. Berbagi Data',
            content:
                'Kami tidak menjual data pribadi Anda ke pihak ketiga. Data hanya dibagikan kepada mitra teknis (Firebase) untuk keperluan penyimpanan dan autentikasi.',
          ),
          _buildSection(
            title: '5. Keamanan',
            content:
                'Data disimpan menggunakan layanan Firebase dengan enkripsi standar industri. Kata sandi Anda tidak pernah disimpan dalam bentuk teks biasa.',
          ),
          _buildSection(
            title: '6. Hak Pengguna',
            content:
                'Anda dapat mengubah atau menghapus data profil kapan saja melalui menu Profil. Untuk penghapusan akun secara permanen, silakan hubungi support@ecolife.app.',
          ),
          _buildSection(
            title: '7. Kontak',
            content:
                'Jika ada pertanyaan mengenai kebijakan privasi ini, hubungi kami di support@ecolife.app.',
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