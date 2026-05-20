import 'package:flutter/material.dart';
import 'package:kegiatin/core/theme/custom.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerTab extends StatefulWidget {
  const QrScannerTab({super.key, this.onDetect});

  final void Function(String value)? onDetect;

  @override
  State<QrScannerTab> createState() => _QrScannerTabState();
}

class _QrScannerTabState extends State<QrScannerTab> {
  final _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDetection(BarcodeCapture capture) {
    if (_isProcessing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    _isProcessing = true;
    widget.onDetect?.call(raw);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isProcessing = false);
    });
  }

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
              // Live camera preview
              MobileScanner(controller: _controller, onDetect: _handleDetection),

              // Overlay viewfinder (blur luar + border sudut)
              CustomPaint(painter: _OverlayPainter(borderColor: colorScheme.primary)),

              // Ikon QR di tengah area scan
              const Center(
                child: Icon(
                  Icons.qr_code_2_rounded,
                  size: 80,
                  color: KegiatinCustomTheme.scannerGhost,
                ),
              ),

              // Kontrol flash & flip — pojok kanan atas
              Positioned(
                top: 12,
                right: 12,
                child: Column(
                  children: [
                    _ControlButton(
                      icon: Icons.flash_on_rounded,
                      tooltip: 'Flash',
                      onTap: () => _controller.toggleTorch(),
                    ),
                    const SizedBox(height: 8),
                    _ControlButton(
                      icon: Icons.flip_camera_ios_rounded,
                      tooltip: 'Balik Kamera',
                      onTap: () => _controller.switchCamera(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Label instruksi
        Container(
          color: colorScheme.surface,
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          child: Text(
            'Arahkan kamera ke QR Code',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
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
    final scanAreaSize = (size.shortestSide * 0.65).clamp(120.0, 280.0);

    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    final overlayPaint = Paint()
      ..color = KegiatinCustomTheme.scannerBackground.withValues(alpha: 0.60);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(14)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlayPaint);

    const cornerLen = 22.0;
    const strokeW = 3.5;
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final corners = [
      [
        Offset(scanRect.left + cornerLen, scanRect.top),
        Offset(scanRect.left, scanRect.top),
        Offset(scanRect.left, scanRect.top + cornerLen),
      ],
      [
        Offset(scanRect.right - cornerLen, scanRect.top),
        Offset(scanRect.right, scanRect.top),
        Offset(scanRect.right, scanRect.top + cornerLen),
      ],
      [
        Offset(scanRect.left + cornerLen, scanRect.bottom),
        Offset(scanRect.left, scanRect.bottom),
        Offset(scanRect.left, scanRect.bottom - cornerLen),
      ],
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
          decoration: const BoxDecoration(
            color: KegiatinCustomTheme.scannerControl,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: KegiatinCustomTheme.onGradient, size: 20),
        ),
      ),
    );
  }
}
