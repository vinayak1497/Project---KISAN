import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'views/home_screen.dart';
import 'views/chatbot_screen.dart';
import 'views/weather_screen.dart';
import 'views/schemes_screen.dart';
import 'views/farmer_news_screen.dart';
import 'views/expert_results_screen.dart';

class ProjectKisanApp extends StatelessWidget {
  const ProjectKisanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Kisan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      // ✅ THIS IS IMPORTANT
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
        '/schemes': (context) => const SchemeAssistantScreen(),
        '/weather': (context) => const WeatherScreen(),
        '/news': (context) => const FarmerNewsScreen(),
         '/expert': (context) => const ExpertHelpScreen(),
      },
    );
  }
}
