enum ActivityFilter {
  all('All'),
  hero('Hero'),
  express('Express'),
  shop('Shop'),
  buy('Buy');

  const ActivityFilter(this.label);
  final String label;
}
