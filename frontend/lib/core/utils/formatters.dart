import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
final _date = DateFormat('MMM d, yyyy');

String money(num? v) => _currency.format(v ?? 0);
String shortDate(DateTime? d) => d == null ? '' : _date.format(d);
