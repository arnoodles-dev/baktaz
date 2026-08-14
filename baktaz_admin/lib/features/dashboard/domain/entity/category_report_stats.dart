import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';

class CategoryReportStats {
  const CategoryReportStats({required this.hero, required this.express, required this.shop, required this.buy});

  final Number hero;
  final Number express;
  final Number shop;
  final Number buy;

  Option<Failure> get validate => hero.validate
      .andThen(() => express.validate)
      .andThen(() => shop.validate)
      .andThen(() => buy.validate)
      .fold(some, (_) => none());
}
