import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.location_city_rounded,
      title: 'Kigali Trails',
      description:
          'Explore the best restaurants, hotels, attractions, and hidden gems across the City of Kigali.',
    ),
    _OnboardingPage(
      icon: Icons.star_rounded,
      title: 'Share Your Favorites',
      description:
          'Create listings for places you love and help others discover what makes Kigali special.',
    ),
    _OnboardingPage(
      icon: Icons.people_rounded,
      title: 'Join the Community',
      description:
          'Connect with locals and travelers. Sign up to start exploring and sharing today.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            size: 64,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          page.title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _currentPage == _pages.length - 1
                  ? Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            ),
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            ),
                            child: const Text(
                              'I Already Have an Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        TextButton(
                          onPressed: () => _pageController.animateToPage(
                            _pages.length - 1,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          ),
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: _goToNext,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Next', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}
