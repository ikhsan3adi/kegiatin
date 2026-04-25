/// Wrapper generik untuk response API yang dipaginasi.
class PaginatedResult<T> {
  final List<T> data;
  final int total;
  final int page;
  final int limit;

  const PaginatedResult({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  int get totalPages => (total / limit).ceil();
  bool get hasNextPage => page < totalPages;
}
