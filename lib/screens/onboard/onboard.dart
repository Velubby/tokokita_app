import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'team_page.dart';

class OnboardingScreen extends StatefulWidget {
  final String userId;

  const OnboardingScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;
  Color activeDotColor = Colors.white;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);

    // Navigate to TeamPage with isFromLogin set to true
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => TeamPage(
        userId: widget.userId,
        teamId: '',
        isFromLogin: true, // This will prevent going back
      ),
    ));
  }

  Widget buildPage({
    required BuildContext context,
    required Color color,
    required String urlImage,
    required String title,
    required String subtitle,
    Color titleColor = Colors.white,
    Color subtitleColor = Colors.white70,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: screenHeight * 0.32,
            child: Image.asset(
              urlImage,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: subtitleColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 1;
                activeDotColor = index == 1 ? Colors.blue : Colors.white;
              });
            },
            children: [
              buildPage(
                context: context,
                color: Colors.blue,
                urlImage: 'assets/images/welcome.png',
                title: 'Welcome to Toko Kita',
                subtitle:
                    'Discover the simple and user-friendly Inventory Management of our app.',
              ),
              buildPage(
                context: context,
                color: Colors.white,
                urlImage: 'assets/images/welcome2.png',
                title: 'Start Managing Inventory',
                subtitle:
                    'Don\'t waste your time, create your team and start managing your inventory now.',
                titleColor: Colors.black,
                subtitleColor: Colors.black54,
              ),
            ],
          ),
          Positioned(
            bottom: 60,
            left: 16,
            right: 16,
            child: isLastPage
                ? ElevatedButton(
                    onPressed: _completeOnboarding,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Get Started',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : Container(),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: 2,
                effect: WormEffect(
                  dotHeight: 12,
                  dotWidth: 12,
                  type: WormType.normal,
                  activeDotColor: activeDotColor,
                  dotColor: Colors.grey,
                ),
                onDotClicked: (index) {
                  _controller.animateToPage(
                    index,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
