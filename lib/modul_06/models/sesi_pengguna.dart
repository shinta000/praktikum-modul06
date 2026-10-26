class SesiPengguna {
  final String token;
  final String email;
  final String nama;
  final String peran;
  final String masukPada;        // ISO-8601, mis. 2026-09-21T08:00:00.000
  final String kedaluwarsaPada;  // ISO-8601

  const SesiPengguna({
    required this.token,
    required this.email,
    required this.nama,
    required this.peran,
    required this.masukPada,
    required this.kedaluwarsaPada,
  });

  factory SesiPengguna.fromJson(Map<String, dynamic> json) {
    return SesiPengguna(
      token: json['token'] as String? ?? '',
      email: json['email'] as String? ?? 'tanpa-email',
      nama: json['nama'] as String? ?? 'Pengguna',
      peran: json['peran'] as String? ?? 'mahasiswa',
      masukPada:
          json['masukPada'] as String? ?? '1970-01-01T00:00:00.000',
      kedaluwarsaPada:
          json['kedaluwarsaPada'] as String? ?? '1970-01-01T00:00:00.000',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'token': token,
        'email': email,
        'nama': nama,
        'peran': peran,
        'masukPada': masukPada,
        'kedaluwarsaPada': kedaluwarsaPada,
      };

  /// Sisa masa berlaku — ditampilkan di beranda.
  Duration sisaWaktu(DateTime sekarang) {
    final DateTime? batas = DateTime.tryParse(kedaluwarsaPada);
    if (batas == null) return Duration.zero;
    final Duration sisa = batas.difference(sekarang);
    return sisa.isNegative ? Duration.zero : sisa;
  }

  SesiPengguna copyWith({
    String? token,
    String? email,
    String? nama,
    String? peran,
    String? masukPada,
    String? kedaluwarsaPada,
  }) {
    return SesiPengguna(
      token: token ?? this.token,
      email: email ?? this.email,
      nama: nama ?? this.nama,
      peran: peran ?? this.peran,
      masukPada: masukPada ?? this.masukPada,
      kedaluwarsaPada: kedaluwarsaPada ?? this.kedaluwarsaPada,
    );
  }
bool sudahKedaluwarsa(DateTime sekarang) {
  final DateTime? batas = DateTime.tryParse(kedaluwarsaPada);
  if (batas == null) return true; // Tanggal rusak = anggap kedaluwarsa.
  return !sekarang.isBefore(batas);
}

/// Versi praktis untuk dipakai di UI (beranda).
bool get kedaluwarsa => sudahKedaluwarsa(DateTime.now());

/// Sesi contoh — dipakai pengujian dan mode simulasi.
static SesiPengguna contoh({
  String token = 'dummy-token-fase-a',
  String email = 'student@trpl.test',
  String nama = 'Mahasiswa TRPL',
  String peran = 'mahasiswa',
  Duration masaBerlaku = const Duration(hours: 2),
  DateTime? sekarang,
}) {
  final DateTime mulai = sekarang ?? DateTime(2026, 9, 21, 8, 0);
  return SesiPengguna(
    token: token,
    email: email,
    nama: nama,
    peran: peran,
    masukPada: mulai.toIso8601String(),
    kedaluwarsaPada: mulai.add(masaBerlaku).toIso8601String(),
  );
}

@override
String toString() =>
    'SesiPengguna(email: $email, peran: $peran, '
    'kedaluwarsaPada: $kedaluwarsaPada)';
    
  /// Label peran yang enak dibaca manusia.
  static String labelPeran(String peran) {
    switch (peran) {
      case 'dosen':
        return 'Dosen';
      case 'mahasiswa':
        return 'Mahasiswa';
      default:
        return 'Pengguna';
    }
  }
}