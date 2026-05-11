import 'package:flutter/material.dart';

/// Koleksi style kustom untuk elemen UI yang belum masuk ke ThemeData.
class KegiatinCustomTheme {
  const KegiatinCustomTheme._();

  // ── Gradient AppBar ───────────────────────────────────────────────────────

  /// Warna gradasi AppBar bagian atas (lebih gelap).
  static const Color appBarTop = Color(0xFF0F3F7A);

  /// Warna gradasi AppBar bagian bawah (lebih terang).
  static const Color appBarBottom = Color(0xFF679AE3);

  /// Warna aksen biru cerah untuk state terpilih di register.
  static const Color selectionBlue = Color(0xFF4DA3FF);

  // ── On-gradient (teks/ikon di atas gradient) ──────────────────────────────

  /// Warna teks/ikon utama di atas gradient AppBar.
  static const Color onGradient = Color(0xFFFFFFFF);

  /// Varian semi-transparan untuk teks/ikon sekunder di atas gradient (70%).
  static const Color onGradientSecondary = Color(0xB3FFFFFF);

  /// Varian lebih redup di atas gradient (85%).
  static const Color onGradientDim = Color(0xD9FFFFFF);

  // ── Glassmorphism / overlay di atas gradient ──────────────────────────────

  /// Background card semi-transparan di atas gradient (15%).
  static const Color glassBackground = Color(0x26FFFFFF);

  /// Border card semi-transparan di atas gradient (25%).
  static const Color glassBorder = Color(0x40FFFFFF);

  /// Background elemen interaktif (avatar, badge) di atas gradient (20%).
  static const Color glassElement = Color(0x33FFFFFF);

  /// Border untuk elemen interaktif di atas gradient (40%).
  static const Color glassElementBorder = Color(0x66FFFFFF);

  /// Border lebih kuat untuk badge di atas gradient (35%).
  static const Color glassBadgeBorder = Color(0x59FFFFFF);

  /// Dropdown / input field semi-transparan di atas gradient (18%).
  static const Color glassInput = Color(0x2EFFFFFF);

  /// Border input field di atas gradient (30%).
  static const Color glassInputBorder = Color(0x4DFFFFFF);

  // ── QR Scanner ────────────────────────────────────────────────────────────

  /// Background gelap untuk preview kamera.
  static const Color scannerBackground = Color(0xFF1A1A1A);

  /// Ikon/elemen ghost di area scanner (20%).
  static const Color scannerGhost = Color(0x33FFFFFF);

  /// Tombol kontrol semi-transparan di scanner (black 45%).
  static const Color scannerControl = Color(0x73000000);

  // ── Shadow ────────────────────────────────────────────────────────────────

  /// Shadow untuk container gradient header (appBarTop 30%).
  static const Color gradientShadow = Color(0x4D0F3F7A);

  // ── Splash page ───────────────────────────────────────────────────────────

  /// Warna gradasi atas halaman splash.
  static const Color splashTop = Color(0xFFD6E8F0);

  /// Warna gradasi bawah halaman splash.
  static const Color splashBottom = Color(0xFFDAE9F1);

  // ── Status semantik ───────────────────────────────────────────────────────

  /// Hijau untuk status "berlangsung" / "ongoing".
  static const Color statusOngoing = Color(0xFF2E7D32);

  /// Hijau untuk SnackBar sukses.
  static const Color snackbarSuccess = Color(0xFF2E7D32);
}
