import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _data = [
    OnboardingData(
      title: "Bienvenue sur PayQr",
      description: "L'élégance du paiement numérique au creux de votre main. Simple, rapide et résolument moderne.",
      image: "assets/images/omboarding/1_images.png",
    ),
    OnboardingData(
      title: "Scannez en un Éclair",
      description: "Oubliez la monnaie et les attentes. Une simple mise au point, et votre transaction est effectuée.",
      image: "assets/images/omboarding/2_images.png",
    ),
    OnboardingData(
      title: "Sécurité Absolue",
      description: "Chaque centime compte. Vos transactions sont protégées par les standards de sécurité les plus élevés.",
      image: "assets/images/omboarding/3_images.png",
    ),
    OnboardingData(
      title: "Libérez votre Quotidien",
      description: "Rejoignez la révolution sans contact. Payez partout, tout le temps, en toute sérénité.",
      image: "assets/images/omboarding/4_images.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1E3A8A); // Bleu profond PayQr

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Le PageView pour les images et textes
          PageView.builder(
            controller: _pageController,
            itemCount: _data.length,
            onPageChanged: (int page) {
              setState(() => _currentPage = page);
            },
            itemBuilder: (context, index) {
              return OnboardingContent(data: _data[index]);
            },
          ),

          // 2. Bouton "Passer" (Skip) - En haut à droite
          if (_currentPage < _data.length - 1)
            Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: () => _pageController.jumpToPage(_data.length - 1),
                child: const Text(
                  "Passer",
                  style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),

          // 3. Navigation en bas
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Indicateurs (Dots)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _data.length,
                    (index) => buildDot(index, _currentPage, primaryBlue),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Boutons de navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Bouton Précédent (Caché sur la page 1)
                    _currentPage > 0
                        ? IconButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                            icon: const Icon(Icons.arrow_back_ios_new, color: primaryBlue),
                          )
                        : const SizedBox(width: 48),

                    // Bouton Suivant / Commencer
                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _data.length - 1) {
                          // Action finale vers la sélection de rôle
                          Navigator.pushNamedAndRemoveUntil(context, '/role_selection', (route) => false);
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text(
                        _currentPage == _data.length - 1 ? "Commencer" : "Suivant",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index, int currentPage, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: currentPage == index ? 24 : 8,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: currentPage == index ? color : color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

// Classe de données
class OnboardingData {
  final String title, description, image;
  OnboardingData({required this.title, required this.description, required this.image});
}

// Widget pour le contenu de chaque page
class OnboardingContent extends StatelessWidget {
  final OnboardingData data;
  const OnboardingContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 80),
        // Image
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(data.image, fit: BoxFit.cover),
            ),
          ),
        ),
        // Texte
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
