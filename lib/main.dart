import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:virtualmakeupapp/Category_Pages/SkinToneAnalyzer.dart';
import 'package:virtualmakeupapp/Main_Screen/AboutPage.dart';
import 'package:virtualmakeupapp/Main_Screen/CartScreen.dart';
import 'package:virtualmakeupapp/Main_Screen/ComparisonToolScreen.dart';
import 'package:virtualmakeupapp/Main_Screen/ContactUsPage.dart';
import 'package:virtualmakeupapp/Main_Screen/HelpCenterPage.dart';
import 'package:virtualmakeupapp/Main_Screen/MyOrdersScreen.dart';
import 'package:virtualmakeupapp/Main_Screen/ProfileScreen.dart';
import 'firebase_options.dart';

// Screens
import 'package:virtualmakeupapp/Login-Signup/LoginScreen.dart';
import 'package:virtualmakeupapp/Login-Signup/SignupScreen.dart';
import 'package:virtualmakeupapp/Main_Screen/home_screen.dart';
import 'package:virtualmakeupapp/Main_Screen/product_detail_screen.dart';
import 'package:virtualmakeupapp/Welcome_Screen/onboarding_screen.dart';
import 'package:virtualmakeupapp/Welcome_Screen/splash.dart';
import 'package:virtualmakeupapp/Welcome_Screen/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Virtual Makeup',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: SplashScreen(),

      // onGenerateRoute handles all navigation with arguments
      onGenerateRoute: (settings) {
        final user = FirebaseAuth.instance.currentUser;

        switch (settings.name) {
          case '/onboarding':
            return MaterialPageRoute(builder: (_) => OnboardingScreen());

          case '/welcome':
            return MaterialPageRoute(builder: (_) => WelcomeScreen());

          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignupScreen());

          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfileScreen());

          case '/orders':
            return MaterialPageRoute(builder: (_) => const MyOrdersScreen());

          case '/ContactUs':
            return MaterialPageRoute(builder: (_) => const ContactUsPage());
          case '/SkinToneAnalyzer':
            return MaterialPageRoute(
              builder: (_) => const SkinToneAnalyzerPage(),
            );

          case '/about':
            return MaterialPageRoute(
              builder: (_) => AboutPage(
                userName: user?.displayName ?? "Guest User",
                userImage: user?.photoURL ?? "https://i.pravatar.cc/150?img=1",
              ),
            );

          case '/helpCenter':
            return MaterialPageRoute(builder: (_) => const HelpCenterPage());

          case '/comparisonTool':
            return MaterialPageRoute(
              builder: (_) => const ComparisonToolScreen(),
            );

          case '/home':
            final userName = user?.displayName ?? 'User';
            return MaterialPageRoute(
              builder: (_) => HomeScreen(userName: userName),
            );

          case '/product':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            final productId = args['productId'] ?? "";
            final userId = args['userId'] ?? "Anonymous";
            final userName = args['userName'] ?? "Anonymous";
            final productData = args['productData'] ?? {}; // ✅ Add this

            return MaterialPageRoute(
              builder: (_) => ProductDetailScreen(
                productId: productId,
                userId: userId,
                userName: userName,
                productData: productData, // ✅ Pass it here
              ),
            );

          // AR Try-On Routes
          case '/cartScreen':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            final cartProducts =
                args['cartProducts'] as List<Map<String, dynamic>>? ?? [];
            return MaterialPageRoute(
              builder: (_) => CartScreen(
                cartProducts: cartProducts,
                cartItems: cartProducts.map((p) => p["id"].toString()).toList(),
              ),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
            );
        }
      },
    );
  }
}
