String formatCOP(double price) {
  final amount = price.round().toString();
  final result = amount.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}.',
  );
  return '\$$result';
}
