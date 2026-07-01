enum ReportCategory {
  sampah,
  drainase,
  jalan,
  pohon,
  polusi,
  lainnya;

  String get label {
    switch (this) {
      case ReportCategory.sampah:
        return 'Sampah';
      case ReportCategory.drainase:
        return 'Drainase';
      case ReportCategory.jalan:
        return 'Jalan';
      case ReportCategory.pohon:
        return 'Pohon';
      case ReportCategory.polusi:
        return 'Polusi';
      case ReportCategory.lainnya:
        return 'Lainnya';
    }
  }
}

enum ReportStatus {
  pending,
  diproses,
  selesai;

  String get label {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.diproses:
        return 'Diproses';
      case ReportStatus.selesai:
        return 'Selesai';
    }
  }
}

enum TransportationType {
  motor,
  mobil,
  angkot,
  bus,
  kereta,
  sepeda,
  jalanKaki;

  String get label {
    switch (this) {
      case TransportationType.motor:
        return 'Motor';
      case TransportationType.mobil:
        return 'Mobil';
      case TransportationType.angkot:
        return 'Angkot';
      case TransportationType.bus:
        return 'Bus';
      case TransportationType.kereta:
        return 'Kereta';
      case TransportationType.sepeda:
        return 'Sepeda';
      case TransportationType.jalanKaki:
        return 'Jalan Kaki';
    }
  }

  double get emissionFactor {
    switch (this) {
      case TransportationType.motor:
        return 0.103;
      case TransportationType.mobil:
        return 0.192;
      case TransportationType.angkot:
        return 0.068;
      case TransportationType.bus:
        return 0.046;
      case TransportationType.kereta:
        return 0.022;
      case TransportationType.sepeda:
        return 0.0;
      case TransportationType.jalanKaki:
        return 0.0;
    }
  }
}

enum UserRole {
  warga,
  adminKomunitas,
  pemerintahDaerah,
  administrator;

  String get label {
    switch (this) {
      case UserRole.warga:
        return 'Warga';
      case UserRole.adminKomunitas:
        return 'Admin Komunitas';
      case UserRole.pemerintahDaerah:
        return 'Pemerintah Daerah';
      case UserRole.administrator:
        return 'Administrator';
    }
  }
}

enum NotificationType {
  reportStatus,
  reward,
  event,
  general;

  String get label {
    switch (this) {
      case NotificationType.reportStatus:
        return 'Status Laporan';
      case NotificationType.reward:
        return 'Reward';
      case NotificationType.event:
        return 'Event';
      case NotificationType.general:
        return 'Umum';
    }
  }
}

enum SortOption {
  terbaru,
  terdekat,
  populer,
  pointTerendah,
  pointTertinggi;

  String get label {
    switch (this) {
      case SortOption.terbaru:
        return 'Terbaru';
      case SortOption.terdekat:
        return 'Terdekat';
      case SortOption.populer:
        return 'Populer';
      case SortOption.pointTerendah:
        return 'Point Terendah';
      case SortOption.pointTertinggi:
        return 'Point Tertinggi';
    }
  }
}
