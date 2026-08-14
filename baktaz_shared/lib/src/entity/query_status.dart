import 'package:freezed_annotation/freezed_annotation.dart';

part 'query_status.freezed.dart';

@freezed
abstract class QueryStatus with _$QueryStatus {
  const factory QueryStatus.initial() = QueryInitial;
  const factory QueryStatus.loading() = QueryLoading;
  const factory QueryStatus.done() = QuerySuccess;

  const QueryStatus._();

  bool get isLoading => this is QueryLoading;
}
