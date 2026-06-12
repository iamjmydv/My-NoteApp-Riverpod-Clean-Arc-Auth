/// Compact "time ago" formatting for note timestamps (e.g. "2h ago", "Mon").
String relativeTime(DateTime? time) {
  if (time == null) return '';
  final now = DateTime.now();
  final diff = now.difference(time);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  if (diff.inDays < 28) return '${(diff.inDays / 7).floor()}w ago';

  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final m = months[time.month - 1];
  return time.year == now.year ? '$m ${time.day}' : '$m ${time.day}, ${time.year}';
}
