import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/constants/app_constants.dart';

// ── Onboarding slide data ─────────────────────────────────────────────────────

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.image,
    required this.tag,
    required this.title,
    required this.subtitle,
  });

  /// Asset path — place onboarding_1.png / _2.png / _3.png in assets/images/
  final String image;

  /// Small pill label above the title
  final String tag;
  final String title;
  final String subtitle;
}

const _slides = [
  _OnboardingSlide(
    image: 'assets/images/onboarding_1.jpeg',
    tag: 'Welcome to Rentora',
    title: 'Find Your\nPerfect Home',
    subtitle:
        'Browse hundreds of verified houses, apartments, hostels and offices across Uganda — all in one place.',
  ),
  _OnboardingSlide(
    image: 'assets/images/onboarding_2.jpeg',
    tag: 'Save & Explore',
    title: 'Save the Ones\nYou Love',
    subtitle:
        'Bookmark your favourite listings and come back to them any time. Compare side by side before you decide.',
  ),
  _OnboardingSlide(
    image: 'assets/images/onboarding_2.webp',
    tag: 'Book with Ease',
    title: 'Book a Viewing\nin Minutes',
    subtitle:
        'Contact landlords directly on WhatsApp or submit a booking request — no agents, no hidden fees.',
  ),
];

const _prefsKey = 'rentora_onboarding_complete';

// ── Page ──────────────────────────────────────────────────────────────────────

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isNavigating = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    if (_isNavigating) return;
    _isNavigating = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
    if (mounted) context.go(AppRoutes.browse);
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Force light icons on the status bar (images are dark / full-bleed)
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // ── Slides ──
            PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) => _SlideView(
                slide: _slides[index],
                isActive: index == _currentPage,
              ),
            ),

            // ── Bottom UI overlay ──
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomControls(
                currentPage: _currentPage,
                total: _slides.length,
                pageController: _pageController,
                onNext: _next,
                onSkip: _complete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Single slide ──────────────────────────────────────────────────────────────

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide, required this.isActive});

  final _OnboardingSlide slide;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        Image.asset(
          slide.image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Container(color: const Color(0xFF1A1A2E)),
        ),

        // Dark gradient — heavier at bottom for text legibility
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.4, 1.0],
              colors: [
                Color(0x33000000), // subtle top tint
                Color(0x00000000), // clear middle
                Color(0xEE000000), // heavy bottom for text
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Bottom controls ───────────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.currentPage,
    required this.total,
    required this.pageController,
    required this.onNext,
    required this.onSkip,
  });

  final int currentPage;
  final int total;
  final PageController pageController;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  bool get _isLast => currentPage == total - 1;

  @override
  Widget build(BuildContext context) {
    final slide = _slides[currentPage];
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(28, 0, 28, bottomPadding + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tag pill ──
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(slide.tag),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Text(
                slide.tag,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── Title ──
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              slide.title,
              key: ValueKey(slide.title),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Subtitle ──
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: Text(
              slide.subtitle,
              key: ValueKey(slide.subtitle),
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 15,
                height: 1.55,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          const SizedBox(height: 36),

          // ── Indicator + buttons row ──
          Row(
            children: [
              // Page dots
              SmoothPageIndicator(
                controller: pageController,
                count: total,
                effect: ExpandingDotsEffect(
                  activeDotColor: Colors.white,
                  dotColor: Colors.white.withOpacity(0.3),
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3.5,
                  spacing: 5,
                ),
              ),

              const Spacer(),

              // Skip (hidden on last slide)
              if (!_isLast)
                GestureDetector(
                  onTap: onSkip,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

              const SizedBox(width: 8),

              // Next / Get Started button
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: FilledButton(
                  onPressed: onNext,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(
                      horizontal: _isLast ? 28 : 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isLast
                        ? const Text(
                            'Get Started',
                            key: ValueKey('start'),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          )
                        : const Icon(
                            Icons.arrow_forward_rounded,
                            key: ValueKey('arrow'),
                            size: 20,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
