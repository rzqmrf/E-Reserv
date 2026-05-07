import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final res = await http.get(Uri.parse('http://localhost:8000/api/fields'));
  final List data = jsonDecode(res.body);
  for (var j in data) {
    var rawPrice = j['price'];
    var pricePerHour = (rawPrice is num) ? (rawPrice as num).toInt() : double.tryParse(rawPrice?.toString() ?? '0')?.toInt() ?? 0;
    print("Name: ${j['name']}, Raw: $rawPrice, Parsed: $pricePerHour");
  }
}
