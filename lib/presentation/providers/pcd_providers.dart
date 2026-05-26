import 'package:kegiatin/data/repositories/pcd_repository_impl.dart';
import 'package:kegiatin/domain/repositories/pcd_repository.dart';
import 'package:kegiatin/domain/usecases/pcd/scan_document_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pcd_providers.g.dart';

@Riverpod(keepAlive: true)
PcdRepository pcdRepository(Ref ref) => PcdRepositoryImpl();

@riverpod
ScanDocumentUseCase scanDocumentUseCase(Ref ref) =>
    ScanDocumentUseCase(ref.watch(pcdRepositoryProvider));
