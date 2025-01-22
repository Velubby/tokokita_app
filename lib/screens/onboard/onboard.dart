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
    required Color color,
    required String urlImage,
    required String title,
    required String subtitle,
    Color titleColor = Colors.white,
    Color subtitleColor = Colors.white70,
  }) {
    return Container(
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            urlImage,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 64),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: subtitleColor,
              ),
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
                color: Colors.blue,
                urlImage: 'assets/images/welcome.png',
                title: 'Welcome to Toko Kita',
                subtitle:
                    'Discover the simple and user-friendly Inventory Management of our app.',
              ),
              buildPage(
                color: Colors.white,
                urlImage: 'assets/images/welcome2.png',
                title: 'Start Managing Inventory',
                subtitle:
                    'Don\'t waste your time, create your team and start managing your inventory now.',
                titleColor: Colors.black,
                subtitleColor: Colors.black,
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
