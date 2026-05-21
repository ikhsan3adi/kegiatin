class ProcessedImage {
  const ProcessedImage({
    required this.filePath,
    required this.enhancementMode,
    required this.fileSize,
    required this.isDocumentScan,
  });

  final String filePath;
  final String enhancementMode;
  final int fileSize;
  final bool isDocumentScan;
}
