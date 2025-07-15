class RssItem {
  final String title;
  final String description;
  final String link;
  final DateTime pubDate;
  final String source;

  RssItem({
    required this.title,
    required this.description,
    required this.link,
    required this.pubDate,
    this.source = "Kisan Jagran",
  });
}
