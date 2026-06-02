import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

/// Utilitas untuk membuat file PDF.
class PdfGenerator {
  /// Mengonversi daftar path file gambar menjadi satu dokumen PDF tunggal.
  /// Mengembalikan path file PDF yang dihasilkan.
  static Future<String> imagesToPdf(List<String> imagePaths) async {
    final pdf = pw.Document();

    for (final path in imagePaths) {
      final imageFile = File(path);
      if (!await imageFile.exists()) continue;

      final imageBytes = await imageFile.readAsBytes();
      final pdfImage = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(pdfImage, fit: pw.BoxFit.contain));
          },
        ),
      );
    }

    final outputDir = await getTemporaryDirectory();
    final outputPath =
        '${outputDir.path}/compiled_materi_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(await pdf.save());

    return outputPath;
  }
}
