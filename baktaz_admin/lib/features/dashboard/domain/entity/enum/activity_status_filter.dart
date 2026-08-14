enum ActivityStatusFilter {
  all('All Status'),
  inProgress('In Progress'),
  completed('Completed');

  const ActivityStatusFilter(this.label);
  final String label;
}
