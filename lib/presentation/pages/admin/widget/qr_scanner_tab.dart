import 'package:flutter/material.dart';

class QrScannerTab extends StatelessWidget {
  const QrScannerTab({super.key, this.onDetect});

  final void Function(String value)? onDetect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background gelap pengganti preview kamera
              const ColoredBox(color: Color(0xFF1A1A1A)),

              // Overlay viewfinder (blur luar + border sudut)
              CustomPaint(painter: _OverlayPainter(borderColor: colorScheme.primary)),

              // Ikon QR di tengah area scan — sinkron dengan pusat viewfinder
              const Center(
                child: Icon(Icons.qr_code_2_rounded, size: 80, color: Color(0x33FFFFFF)),
              ),

              // Kontrol flash & flip — pojok kanan atas
              Positioned(
                top: 12,
                right: 12,
                child: Column(
                  children: [
                    _ControlButton(icon: Icons.flash_on_rounded, tooltip: 'Flash', onTap: () {}),
                    const SizedBox(height: 8),
                    _ControlButton(
                      icon: Icons.flip_camera_ios_rounded,
                      tooltip: 'Balik Kamera',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Label instruksi (di luar area kamera, tidak bertumpuk) ─────────
        Container(
          color: colorScheme.surface,
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          child: Text(
            'Arahkan kamera ke QR Code',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),

        // ── Tombol simulasi ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => onDetect?.call('SIMULASI_QR_TOKEN_12345'),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Simulasi Scan QR'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Overlay gelap di sekitar area viewfinder dengan border sudut L-shape.
class _OverlayPainter extends CustomPainter {
  const _OverlayPainter({required this.borderColor});
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Responsif: 65 % sisi terpendek, maks 280 dp
    final scanAreaSize = (size.shortestSide * 0.65).clamp(120.0, 280.0);

    // Viewfinder tepat di tengah canvas
    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    // Overlay gelap di luar area scan
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.60);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(14)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlayPaint);

    // Border sudut L-shape
    const cornerLen = 22.0;
    const strokeW = 3.5;
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final corners = [
      // Top-left
      [
        Offset(scanRect.left + cornerLen, scanRect.top),
        Offset(scanRect.left, scanRect.top),
        Offset(scanRect.left, scanRect.top + cornerLen),
      ],
      // Top-right
      [
        Offset(scanRect.right - cornerLen, scanRect.top),
        Offset(scanRect.right, scanRect.top),
        Offset(scanRect.right, scanRect.top + cornerLen),
      ],
      // Bottom-left
      [
        Offset(scanRect.left + cornerLen, scanRect.bottom),
        Offset(scanRect.left, scanRect.bottom),
        Offset(scanRect.left, scanRect.bottom - cornerLen),
      ],
      // Bottom-right
      [
        Offset(scanRect.right - cornerLen, scanRect.bottom),
        Offset(scanRect.right, scanRect.bottom),
        Offset(scanRect.right, scanRect.bottom - cornerLen),
      ],
    ];

    for (final pts in corners) {
      canvas.drawPath(
        Path()
          ..moveTo(pts[0].dx, pts[0].dy)
          ..lineTo(pts[1].dx, pts[1].dy)
          ..lineTo(pts[2].dx, pts[2].dy),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter old) => old.borderColor != borderColor;
}

/// Tombol ikon bulat semi-transparan.
class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
