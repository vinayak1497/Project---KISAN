import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Kisan Mitra",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 16),
          Icon(Icons.settings, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🌤️ Weather Card
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/weather');
              },
              child: _buildWeatherCard(),
            ),

            const SizedBox(height: 16),

            // 💹 Market Price Card
            _buildMarketPriceCard(),

            const SizedBox(height: 24),

            // 🎙️ Voice Assistant Button
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Icons.mic, size: 32, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  const Text("Ask your assistant", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🧩 Feature Grid (Includes Farmer News Button)
            _buildFeatureGrid(context),

            const SizedBox(height: 24),

            // 🛒 Marketplace Scroll
            const Text("Community Market", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(5, (index) => _buildMarketItem(index)),
              ),
            ),
          ],
        ),
      ),

      // 🚀 Bottom Nav Bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.home), onPressed: () {}),
            const SizedBox(width: 40), // space for FAB
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

  Widget _buildWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("📍 Mumbai", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.wb_sunny, size: 40),
              SizedBox(width: 12),
              Text("30°C - Sunny", style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              return Column(
                children: const [
                  Icon(Icons.cloud, size: 20),
                  SizedBox(height: 4),
                  Text("28°C", style: TextStyle(fontSize: 12)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketPriceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Market Prices", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _buildCropPrice("Wheat", "₹22/kg", true),
            _buildCropPrice("Onion", "₹15/kg", false),
            _buildCropPrice("Tomato", "₹20/kg", true),
          ]),
        ],
      ),
    );
  }

  Widget _buildCropPrice(String crop, String price, bool isUp) {
    return Column(
      children: [
        Text(crop, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        Text(price, style: const TextStyle(fontWeight: FontWeight.w500)),
        Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    List<Map<String, dynamic>> features = [
      {'label': 'Govt Schemes', 'icon': Icons.account_balance, 'route': '/schemes'},
      {'label': 'Farmer News', 'icon': Icons.article, 'route': '/news'},
      {'label': 'AI Chatbot', 'icon': Icons.chat, 'route': '/chatbot'},
      {'label': 'Expert Help', 'icon': Icons.help_outline, 'route': '/expert'},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      children: features.map((item) {
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, item['route']);
          },
          child: Container(
            decoration: _cardDecoration(),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'], size: 32),
                const SizedBox(height: 8),
                Text(item['label'], style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMarketItem(int index) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shopping_bag_outlined, size: 28),
          SizedBox(height: 8),
          Text("Corn", style: TextStyle(fontSize: 12)),
          Text("₹18/kg", style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade300,
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );  
  }
}
