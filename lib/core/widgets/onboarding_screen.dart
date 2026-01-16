import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String>? features;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.features,
  });
}

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Bienvenue sur Finance',
      description: 'Votre assistant personnel pour gérer vos finances au quotidien.',
      icon: Icons.account_balance_wallet,
      color: AppColors.primaryGreen,
    ),
    OnboardingPage(
      title: 'Gérez vos Transactions',
      description: 'Ajoutez facilement vos revenus et dépenses pour suivre vos flux financiers.',
      icon: Icons.swap_horiz,
      color: Colors.blue,
      features: [
        '💰 Revenus par source',
        '💸 Dépenses par catégorie',
        '📊 Visualisation en temps réel',
        '🔄 Historique complet',
      ],
    ),
    OnboardingPage(
      title: 'Budgets Intelligents',
      description: 'Créez des budgets mensuels et recevez des alertes en temps réel.',
      icon: Icons.pie_chart,
      color: Colors.purple,
      features: [
        '🎯 Budgets par catégorie',
        '⚠️ Alertes de dépassement',
        '📈 Suivi progression',
        '💡 Recommandations',
      ],
    ),
    OnboardingPage(
      title: 'Dettes & Créances',
      description: 'Suivez vos dettes et créances avec historique de paiements.',
      icon: Icons.people,
      color: Colors.orange,
      features: [
        '💳 Gestion des dettes',
        '💵 Suivi des créances',
        '📅 Paiements partiels',
        '🔔 Rappels automatiques',
      ],
    ),
    OnboardingPage(
      title: 'Épargne & Objectifs',
      description: 'Définissez vos objectifs d\'épargne et suivez votre progression.',
      icon: Icons.savings,
      color: Colors.green,
      features: [
        '🎯 Objectifs personnalisés',
        '💰 Contributions régulières',
        '📊 Progression visuelle',
        '✅ Notifications succès',
      ],
    ),
    OnboardingPage(
      title: 'Statistiques Avancées',
      description: 'Visualisez vos finances avec des graphiques interactifs.',
      icon: Icons.bar_chart,
      color: Colors.pink,
      features: [
        '📊 Graphiques circulaires',
        '📈 Évolution mensuelle',
        '🔍 Analyse par période',
        '💡 Insights automatiques',
      ],
    ),
    OnboardingPage(
      title: 'Export & Sauvegarde',
      description: 'Exportez vos données et créez des sauvegardes sécurisées.',
      icon: Icons.cloud_download,
      color: Colors.teal,
      features: [
        '📄 Export CSV/Excel',
        '☁️ Synchronisation cloud',
        '🔒 Données sécurisées',
        '📱 Multi-appareils',
      ],
    ),
    OnboardingPage(
      title: 'Prêt à Commencer !',
      description: 'Tout est configuré. Commencez dès maintenant à prendre le contrôle de vos finances.',
      icon: Icons.check_circle,
      color: AppColors.accentBlue,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  void _skip() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skip,
                child: const Text(
                  'Passer',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page Indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildIndicator(index == _currentPage),
                ),
              ),
            ),

            // Next/Get Started Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_currentPage].color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Commencer 🚀'
                        : 'Suivant',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          
          // Icon with gradient background
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  page.color.withOpacity(0.8),
                  page.color.withOpacity(0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: page.color.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 70,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
          
          // Features List (if provided)
          if (page.features != null) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: page.color.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: page.features!.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          feature.split(' ')[0],
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature.substring(feature.indexOf(' ') + 1),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryGreen : AppColors.textMuted.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
