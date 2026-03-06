import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:virtualmakeupapp/Welcome_Screen/welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // PAGES
          PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 2;
              });
            },
            children: [
              buildPage(
                title: "Try Makeup Virtually",
                subtitle: "Experience real-time makeup using AR camera.",
                lottie: "assets/ar.json",
              ),
              buildPage(
                title: "Personal Recommendations",
                subtitle: "Get beauty suggestions based on your look.",
                lottie: "assets/Makeup.json",
              ),
              buildPage(
                title: "Compare Before Buying",
                subtitle: "Check shades & products before you shop.",
                lottie: "assets/hair.json",
              ),
            ],
          ),

          // Skip Button
          Positioned(
            right: 16,
            top: 50,
            child: TextButton(
              child: Text(
                "Skip",
                style: TextStyle(
                  fontSize: 16,
                  color: const Color.fromARGB(177, 8, 46, 92),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                );
              },
            ),
          ),

          // Page Indicator + Next/Get Started
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: controller,
                  count: 3,
                  effect: WormEffect(
                    dotColor: Colors.grey.shade300,
                    activeDotColor: const Color.fromARGB(177, 8, 46, 92),
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                ),
                SizedBox(height: 20),

                // NEXT / GET STARTED
                isLastPage
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WelcomeScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(177, 8, 46, 92),
                          padding: EdgeInsets.symmetric(
                            horizontal: 100,
                            vertical: 16,
                          ),
                          shape: StadiumBorder(),
                        ),
                        child: Text(
                          "Get Started",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          controller.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(177, 8, 46, 92),
                          padding: EdgeInsets.symmetric(
                            horizontal: 100,
                            vertical: 16,
                          ),
                          shape: StadiumBorder(),
                        ),
                        child: Text(
                          "Next",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage({
    required String title,
    required String subtitle,
    required String lottie,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(lottie, height: 320),
          SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
