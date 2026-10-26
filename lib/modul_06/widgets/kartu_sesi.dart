import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sesi_pengguna.dart';

class KartuSesi extends StatefulWidget {
  final SesiPengguna sesi;
  final DateTime sekarang; // Tetap dipertahankan sesuai kontrak Fase A
  final VoidCallback? onKeluar;
  final bool sedangKeluar;
  final bool tampilkanToken;

  const KartuSesi({
    super.key,
    required this.sesi,
    required this.sekarang,
    this.onKeluar,
    this.sedangKeluar = false,
    this.tampilkanToken = false,
  });

  static String samarkanToken(String token) {
    if (token.isEmpty) return '(kosong)';
    if (token.length <= 6) return _titik(token.length);
    return '${token.substring(0, 6)}${_titik(12)}';
  }

  static String _titik(int jumlah) =>
      List<String>.filled(jumlah, '\u2022').join();

  static String formatWaktu(String iso) {
    const List<String> bulan = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final DateTime? waktu = DateTime.tryParse(iso);
    if (waktu == null) return 'tidak diketahui';
    final String jam = waktu.hour.toString().padLeft(2, '0');
    final String menit = waktu.minute.toString().padLeft(2, '0');
    return '${waktu.day} ${bulan[waktu.month - 1]} ${waktu.year}, '
        '$jam:$menit';
  }

  static String formatSisa(Duration sisa) {
    if (sisa.inSeconds <= 0) return 'sudah berakhir';
    if (sisa.inMinutes < 1) return '${sisa.inSeconds} detik';
    if (sisa.inHours < 1) return '${sisa.inMinutes} menit';
    final int menit = sisa.inMinutes.remainder(60);
    return menit == 0
        ? '${sisa.inHours} jam'
        : '${sisa.inHours} jam $menit menit';
  }

  @override
  State<KartuSesi> createState() => _KartuSesiState();
}

class _KartuSesiState extends State<KartuSesi> {
  late Timer _timer;
  late DateTime _waktuSekarang;

  @override
  void initState() {
    super.initState();
    _waktuSekarang = widget.sekarang;
    
    // Timer berjalan setiap detik
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _waktuSekarang = DateTime.now(); // Update waktu setiap detik
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Wajib dibatalkan sesuai petunjuk modul
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Duration sisa = widget.sesi.sisaWaktu(_waktuSekarang);
    final bool kritis = sisa.inMinutes < 5; // Warna merah jika < 5 menit

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.sesi.nama,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(widget.sesi.email),
            Text('Peran: ${SesiPengguna.labelPeran(widget.sesi.peran)}'),
            const Divider(height: 24),
            Text('Masuk: ${KartuSesi.formatWaktu(widget.sesi.masukPada)}'),
            
            // Teks Sisa Waktu yang berubah warna
            Text(
              'Sisa Waktu: ${KartuSesi.formatSisa(sisa)}',
              style: TextStyle(
                color: kritis ? Colors.red : null,
                fontWeight: kritis ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            
            Text('Token: ${widget.tampilkanToken ? widget.sesi.token : KartuSesi.samarkanToken(widget.sesi.token)}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.sedangKeluar ? null : widget.onKeluar,
                child: widget.sedangKeluar
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Keluar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}