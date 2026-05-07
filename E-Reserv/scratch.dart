void main() {
  var json = {'price': '150000.00'};
  var parsed = (json['price'] is num) ? (json['price'] as num).toInt() : double.tryParse(json['price']?.toString() ?? '0')?.toInt() ?? 0;
  print("Parsed price: $parsed");
}
