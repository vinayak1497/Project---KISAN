import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Scheme {
  final String title, summary, eligibility, url;
  Scheme({required this.title, required this.summary, required this.eligibility, required this.url});
}

class SchemeAssistantScreen extends StatefulWidget {
  const SchemeAssistantScreen({super.key});
  @override
  State<SchemeAssistantScreen> createState() => _SchemeAssistantScreenState();
}

class _SchemeAssistantScreenState extends State<SchemeAssistantScreen> {
  List<Scheme> _schemes = [];
  bool _isLoading = true;
  String _keyword = '';
  Map<String,String> _filters = {};
  
  @override
  void initState() {
    super.initState();
    _fetchSchemes();
  }

Future<void> _fetchSchemes() async {
  setState(() => _isLoading = true);

  final prompt = '''
List Indian government schemes that help farmers ${_keyword.isNotEmpty ? "related to $_keyword" : ""}${_filters.isNotEmpty ? " with filters: ${_filters.toString()}" : ""}.
Return ONLY a JSON array of objects with:
- title
- summary
- eligibility
- url
Return the response as pure JSON without code formatting, markdown, or explanation.
''';

  final res = await http.post(
    Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyCzNfaMSGCvoCVjrFdUo2fAV8yXNK9WK-g'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ]
    }),
  );

  try {
    final out = jsonDecode(res.body);
    final raw = out['candidates'][0]['content']['parts'][0]['text'];
    final clean = raw.replaceAll(RegExp(r'^```json|```$', multiLine: true), '').trim();

    final List<dynamic> arr = jsonDecode(clean);
    setState(() {
      _schemes = arr.map((e) => Scheme(
        title: e['title'],
        summary: e['summary'],
        eligibility: e['eligibility'],
        url: e['url'],
      )).toList();
      _isLoading = false;
    });
  } catch (e) {
    print("Parsing failed: $e");
    setState(() => _isLoading = false);
  }
}


  void _openFilters() async {
    final result = await showDialog<Map<String,String>>(
      context: context,
      builder: (_) => FilterDialog(filters: _filters),
    );
    if (result != null) {
      _filters = result;
      _fetchSchemes();
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: .5,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(c)),
        title: const Text("Government Schemes", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.filter_list, color: Colors.black), onPressed: _openFilters)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Search by keyword (e.g., irrigation, subsidy)",
              filled:true,fillColor:Colors.grey.shade100,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius:BorderRadius.circular(12), borderSide: BorderSide(color:Colors.grey.shade400)),
            ),
            onSubmitted: (v){_keyword=v; _fetchSchemes();},
          ),
          const SizedBox(height:12),
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _schemes.isEmpty
                ? const Center(child: Text("No schemes found for your criteria.\nTry adjusting filters.", textAlign: TextAlign.center))
                : ListView.builder(
                    itemCount: _schemes.length,
                    itemBuilder:(ctx,i){
                      final s = _schemes[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom:12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation:2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              Text(s.title, style: const TextStyle(fontSize:18, fontWeight: FontWeight.bold)),
                              const SizedBox(height:6),
                              Text(s.summary, maxLines:2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize:14)),
                              const SizedBox(height:6),
                              Text("Eligibility: ${s.eligibility}", style: const TextStyle(fontSize:14)),
                              const SizedBox(height:10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () async {
                                    final uri = Uri.parse(s.url);
                                    if (await canLaunchUrl(uri)) launchUrl(uri);
                                  },
                                  child: const Text("Know More →"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          )
        ]),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), notchMargin:8,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          IconButton(icon: const Icon(Icons.home), onPressed: () {}),
          const SizedBox(width:40),
          IconButton(icon: const Icon(Icons.person), onPressed: () {}),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, backgroundColor: Colors.black, child: const Icon(Icons.qr_code_scanner),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class FilterDialog extends StatefulWidget {
  final Map<String,String> filters;
  const FilterDialog({super.key, required this.filters});
  @override State<FilterDialog> createState() => _FilterDialogState();
}
class _FilterDialogState extends State<FilterDialog> {
  late Map<String,String> f;
  @override void initState(){ super.initState(); f=Map.from(widget.filters); }

  Widget dd(String label, List<String> opts){
    return DropdownButtonFormField<String>(
      value: f[label],
      hint: Text(label),
      items: opts.map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),
      onChanged: (v){ f[label]=v!; },
    );
  }

  @override Widget build(BuildContext c){
    return AlertDialog(
      title: const Text("Filters"),
      content: SingleChildScrollView(
        child: Column(children:[
          dd("State", ["All","Punjab","Maharashtra","UP"]),
          dd("Farmer Type", ["All","Small","Marginal","Organic"]),
          dd("Age Group", ["All","Below 30","30–60","60+"]),
          dd("Income Range", ["All","<2L","2–5L",">5L"]),
          dd("Crop Type", ["All","Wheat","Rice","Cotton"]),
        ]),
      ),
      actions:[
        TextButton(onPressed: ()=>Navigator.pop(c), child: const Text("Cancel")),
        ElevatedButton(onPressed: ()=>Navigator.pop(c, f), child: const Text("Apply")),
      ],
    );
  }
}
