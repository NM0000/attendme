import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'choose_option_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticInOut),
    );

    _animationController.forward();
  }

  void _navigateToNextScreen(BuildContext context) {
    if (!_isNavigating) {
      setState(() {
        _isNavigating = true;
      });
      _animationController.reverse().then((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChooseOptionScreen()),
        );
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4F1), // Updated background color
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveValue<double>(
                context,
                defaultValue: 40.0,
                conditionalValues: [
                  Condition.smallerThan(name: MOBILE, value: 20.0),
                  Condition.largerThan(name: TABLET, value: 60.0),
                ],
              ).value,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ScaleTransition(
                  scale: _bounceAnimation,
                  child: Image.asset(
                    'assets/logo.png',
                    width: ResponsiveValue<double>(
                      context,
                      defaultValue: 200.0,
                      conditionalValues: [
                        Condition.smallerThan(name: MOBILE, value: 120.0),
                        Condition.largerThan(name: TABLET, value: 240.0),
                      ],
                    ).value,
                    height: ResponsiveValue<double>(
                      context,
                      defaultValue: 200.0,
                      conditionalValues: [
                        Condition.smallerThan(name: MOBILE, value: 120.0),
                        Condition.largerThan(name: TABLET, value: 240.0),
                      ],
                    ).value,
                    semanticLabel: 'AttendMe Logo',
                  ),
                ),
                SizedBox(height: ResponsiveValue<double>(
                  context,
                  defaultValue: 20.0,
                  conditionalValues: [
                    Condition.smallerThan(name: MOBILE, value: 10.0),
                    Condition.largerThan(name: TABLET, value: 30.0),
                  ],
                ).value),
                Text(
                  'AttendMe',
                  style: TextStyle(
                    fontSize: ResponsiveValue<double>(
                      context,
                      defaultValue: 28.0,
                      conditionalValues: [
                        Condition.smallerThan(name: MOBILE, value: 18.0),
                        Condition.largerThan(name: TABLET, value: 32.0),
                      ],
                    ).value,
                    color: Color(0xFF00796B), // Updated primary color
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: ResponsiveValue<double>(
                  context,
                  defaultValue: 20.0,
                  conditionalValues: [
                    Condition.smallerThan(name: MOBILE, value: 10.0),
                    Condition.largerThan(name: TABLET, value: 30.0),
                  ],
                ).value),
                Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveValue<double>(
                      context,
                      defaultValue: 16.0,
                      conditionalValues: [
                        Condition.smallerThan(name: MOBILE, value: 14.0),
                        Condition.largerThan(name: TABLET, value: 18.0),
                      ],
                    ).value,
                    color: Color(0xFF212121), // Updated text color
                  ),
                ),
                SizedBox(height: ResponsiveValue<double>(
                  context,
                  defaultValue: 50.0,
                  conditionalValues: [
                    Condition.smallerThan(name: MOBILE, value: 30.0),
                    Condition.largerThan(name: TABLET, value: 60.0),
                  ],
                ).value),
                GestureDetector(
                  onTap: () => _navigateToNextScreen(context),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Image.asset(
                          'assets/next.png',
                          width: ResponsiveValue<double>(
                            context,
                            defaultValue: 100.0,
                            conditionalValues: [
                              Condition.smallerThan(name: MOBILE, value: 70.0),
                              Condition.largerThan(name: TABLET, value: 120.0),
                            ],
                          ).value,
                          height: ResponsiveValue<double>(
                            context,
                            defaultValue: 100.0,
                            conditionalValues: [
                              Condition.smallerThan(name: MOBILE, value: 70.0),
                              Condition.largerThan(name: TABLET, value: 120.0),
                            ],
                          ).value,
                          semanticLabel: 'Next Button',
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: ResponsiveValue<double>(
                  context,
                  defaultValue: 20.0,
                  conditionalValues: [
                    Condition.smallerThan(name: MOBILE, value: 10.0),
                    Condition.largerThan(name: TABLET, value: 30.0),
                  ],
                ).value),
                Text(
                  'Click here to get started',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveValue<double>(
                      context,
                      defaultValue: 16.0,
                      conditionalValues: [
                        Condition.smallerThan(name: MOBILE, value: 14.0),
                        Condition.largerThan(name: TABLET, value: 18.0),
                      ],
                    ).value,
                    color: Color(0xFF009688), // Updated accent color
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
