enum TimeFilter {
  today('Today'),
  last7Days('Last 7 Days'),
  last30Days('Last 30 Days');

  const TimeFilter(this.label);
  final String label;
}
