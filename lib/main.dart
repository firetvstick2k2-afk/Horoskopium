import 'package:flutter/material.dart';
import 'screens/profiles_screen.dart';

void main() {
  runApp(const HoroskopiumApp());
}

class HoroskopiumApp extends StatelessWidget {
  const HoroskopiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF17263D);
    const parchment = Color(0xFFF4EBDD);
    const gold = Color(0xFFB18A4A);

    return MaterialApp(
      title: 'Horoskopium',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: parchment,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ink,
          brightness: Brightness.light,
          primary: ink,
          secondary: gold,
          surface: const Color(0xFFFBF7EF),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: ink,
          foregroundColor: parchment,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFBF7EF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFDCCBAE)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HOROSKOPIUM',
          style: TextStyle(
            letterSpacing: 3.2,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfilesScreen()),
            ),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: const [
            _WelcomeHeader(),
            SizedBox(height: 22),
            _BirthChartCard(),
            SizedBox(height: 16),
            _SectionHeading(title: 'DEIN UNIVERSUM'),
            SizedBox(height: 10),
            _FeatureTile(
              icon: Icons.public,
              title: 'Geburtshoroskop',
              subtitle: 'Radix, Häuser, Planeten und Aspekte',
            ),
            _FeatureTile(
              icon: Icons.favorite_outline,
              title: 'Partnerschaft',
              subtitle: 'Synastrie und Composit-Horoskop',
            ),
            _FeatureTile(
              icon: Icons.auto_awesome,
              title: 'Aktuelle Transite',
              subtitle: 'Die astrologischen Zeitqualitäten',
            ),
            _FeatureTile(
              icon: Icons.menu_book_outlined,
              title: 'Dein persönlicher Bericht',
              subtitle: 'Ausführliche Deutungen und PDF-Ausgabe',
            ),
            SizedBox(height: 18),
            Center(
              child: Text(
                'WISSEN • SYMBOLIK • SELBSTERKENNTNIS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF82745F),
                  letterSpacing: 1.4,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Die Sprache der Sterne',
          style: TextStyle(
            color: Color(0xFF17263D),
            fontSize: 27,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Entdecke dein persönliches Himmelsbild.',
          style: TextStyle(color: Color(0xFF716653), fontSize: 15),
        ),
      ],
    );
  }
}

class _BirthChartCard extends StatelessWidget {
  const _BirthChartCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF17263D),
                border: Border.all(color: const Color(0xFFB18A4A), width: 2),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFE6C98F),
                  size: 48,
                ),
              ),
            ),
            const SizedBox(width: 18),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dein Geburtshoroskop',
                    style: TextStyle(
                      color: Color(0xFF17263D),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Lege dein Geburtsprofil an und entdecke dein persönliches Radix.',
                    style: TextStyle(
                      color: Color(0xFF716653),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'PROFIL ANLEGEN  →',
                    style: TextStyle(
                      color: Color(0xFF9A7135),
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF9A7135),
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
        fontSize: 11,
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFECE1CE),
          foregroundColor: const Color(0xFF17263D),
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF17263D),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF716653)),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF9A7135),
        ),
        onTap: title == 'Geburtshoroskop'
            ? () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfilesScreen()),
                )
            : null,
      ),
    );
  }
}
