import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/presentation/providers/providers.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Data untuk 3 slide
  final List<Map<String, String>> onboardingData = [
    {
      "desc":
          "Aplikasi manajemen kegiatan rutin biar semua jadi lebih rapi.",
      "image": "assets/images/onboarding1.png",
    },
    {
      "desc":
          "Atur kegiatan, presensi, dan materi dalam satu aplikasi.",
      "image": "assets/images/onboarding2.png",
    },
    {
      "desc":
          "Lebih praktis, terorganisir, dan gak ribet.",
      "image": "assets/images/onboarding3.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final brandColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            // Ukuran responsif berdasarkan tinggi layar
            final imageHeight = (screenHeight * 0.35).clamp(140.0, 320.0);
            final spacingSmall = (screenHeight * 0.015).clamp(6.0, 15.0);
            final spacingMedium = (screenHeight * 0.025).clamp(10.0, 30.0);
            final logoSize = (screenHeight * 0.035).clamp(22.0, 36.0);

            return Column(
              children: [
                // Branding kiri atas: logo + teks KEGIATIN
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    top: 12,
                    right: 20,
                    bottom: 4,
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/logo_kegiatin.png',
                        width: logoSize,
                        height: logoSize,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'KEGIATIN',
                        style: TextStyle(
                          fontSize: logoSize * 0.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: brandColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Slide konten (deskripsi di atas, gambar di bawah)
                Expanded(
                  flex: 4,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemCount: onboardingData.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          SizedBox(height: spacingMedium),
                          // Teks deskripsi
                          Text(
                            onboardingData[index]["desc"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                              color: brandColor,
                            ),
                          ),
                          const Spacer(),
                          // Gambar ilustrasi (center)
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: imageHeight,
                            ),
                            child: Image.asset(
                              onboardingData[index]["image"]!,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),

                // Indikator titik
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingData.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: spacingMedium),

                // Tombol Login & Sign Up
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: spacingSmall,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => context.go('/register'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(height: spacingSmall),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => context.go('/login'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacingSmall),
              ],
            );
          },
        ),
      ),
    );
  }
}