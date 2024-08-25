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
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _navigateToNextScreen(BuildContext context) {
    if (!_isNavigating) {
      setState(() {
        _isNavigating = true;
      });
      _animationController.forward().then((_) {
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
      backgroundColor: Colors.white,
      body: Center(
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
              Image.asset(
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
                    defaultValue: 24.0,
                    conditionalValues: [
                      Condition.smallerThan(name: MOBILE, value: 18.0),
                      Condition.largerThan(name: TABLET, value: 28.0),
                    ],
                  ).value,
                  color: Colors.green,
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
                  color: Colors.grey,
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
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
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
                        ),
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
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
