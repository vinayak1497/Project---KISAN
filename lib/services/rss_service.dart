import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/rss_item.dart';

Future<List<RssItem>> fetchRssItems(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final document = XmlDocument.parse(response.body);
    final items = document.findAllElements('item');
    return items.map((item) {
      final pubDateStr = item.getElement('pubDate')?.text ?? '';
      final pubDate = DateTime.tryParse(pubDateStr) ?? DateTime.now();
      return RssItem(
        title: item.getElement('title')?.text ?? 'No title',
        description: item.getElement('description')?.text ?? 'No description',
        link: item.getElement('link')?.text ?? '',
        pubDate: pubDate,
      );
    }).toList();
  } else {
    throw Exception('Failed to load RSS feed');
  }
}
