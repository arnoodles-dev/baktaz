import 'package:intl/intl.dart';

abstract class MoneyFormatter {
  static const String currencySign = '₱';

  static String format(double balance, {bool onlyAbsolute = false}) {
    final NumberFormat formatRule = NumberFormat('#,##0.00');
    final String formattedBalance = formatRule.format(onlyAbsolute ? balance.abs() : balance);

    return '₱$formattedBalance';
  }

  static String formatWithoutSymbol(double balance) {
    final NumberFormat formatRule = NumberFormat('#,##0.00');

    return formatRule.format(balance);
  }

  static String unformat(String formattedBalance) => formattedBalance.replaceAll(currencySign, '').replaceAll(',', '');

  static String? unformatNullable(String? formattedBalance) =>
      formattedBalance?.replaceAll(currencySign, '').replaceAll(',', '');

  static String formatNegative(double balance) {
    final NumberFormat formatRule = NumberFormat('#,##0.00');
    final String formattedBalance = formatRule.format(balance.abs());

    return '-₱$formattedBalance';
  }

  static String formatIncludingNegative(double balance) {
    final NumberFormat formatRule = NumberFormat('#,##0.00');
    final String formattedBalance = formatRule.format(balance.abs());

    return balance.isNegative ? '-₱$formattedBalance' : '₱$formattedBalance';
  }

  static String formatObscured() => '₱••••';

  static String formatObscuredNoSymbol() => '••••';
}
