import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/rss_item.dart';
import '../services/rss_service.dart';

class FarmerNewsScreen extends StatefulWidget {
  const FarmerNewsScreen({super.key});

  @override
  State<FarmerNewsScreen> createState() => _FarmerNewsScreenState();
}

class _FarmerNewsScreenState extends State<FarmerNewsScreen> {
  List<RssItem> _items = [];
  List<RssItem> _filteredItems = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  void _loadNews() async {
    setState(() => _isLoading = true);
    try {
      final data = await fetchRssItems("https://krishijagran.com/feeds/rss");
      setState(() {
        _items = data;
        _filteredItems = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("RSS fetch failed: $e");
    }
  }

  void _filterNews(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filteredItems = _items.where((item) =>
        item.title.toLowerCase().contains(q) ||
        item.description.toLowerCase().contains(q)).toList();
    });
  }

  String _timeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    return DateFormat('dd MMM, h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Farmer News", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadNews,
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredItems.isEmpty
              ? const Center(child: Text("No news updates at the moment."))
              : Column(
                  children: [
                    // 🔍 Search Bar
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterNews,
                        decoration: InputDecoration(
                          hintText: "Search news (e.g., tomato price, rainfall)",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                        ),
                      ),
                    ),

                    // 📰 News Cards
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredItems.length,
                        padding: const EdgeInsets.all(12),
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.title,
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "🕒 ${_timeAgo(item.pubDate)}",
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                      Text("Kisan Jagran",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () async {
                                        final uri = Uri.parse(item.link);
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri);
                                        }
                                      },
                                      child: const Text("Read More →"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

      // 🔽 Bottom Navigation
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.home), onPressed: () {}),
            const SizedBox(width: 40),
            IconButton(icon: const Icon(Icons.person), onPressed: () {}),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.black,
        child: const Icon(Icons.qr_code_scanner),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
