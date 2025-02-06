import 'package:flutter/material.dart';
import 'package:lego_app/screens/login.dart';
import 'package:lottie/lottie.dart';

class ExplinationScreen extends StatefulWidget {
  const ExplinationScreen({super.key});

  @override
  State<ExplinationScreen> createState() => _ExplinationScreenState();
}

class _ExplinationScreenState extends State<ExplinationScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final List<Map<String, dynamic>> _steps = [
    {
      'animation': 'assets/animations/welcome.json',
      'title': 'مرحبا بك في برنامج اداره المخازن',
      'description':
          'This app is designed to help you manage your store efficiently',
    },
    {
      'animation': 'assets/animations/add_product.json',
      'title': 'أضافه المنتجات',
      'description': 'Easily add products to your store with a few clicks',
    },
    {
      'animation': 'assets/animations/manage.json',
      'title': 'اداره الطلبات',
      'description': 'Keep track of all your orders and manage them easily',
    },
    {
      'animation': 'assets/animations/gonow.json',
      'title': 'أبدء البيع',
      'description':
          'Youre all set to start selling in bulk with LegoMensWear.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _steps.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildStepItem(_steps[index]);
            },
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentIndex > 0)
                      ElevatedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Text('Previous'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[900],
                        ),
                      ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_currentIndex < _steps.length - 1) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                          );
                        }
                      },
                      child: Text(_currentIndex < _steps.length - 1
                          ? 'Next'
                          : 'Get Started'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _steps.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(Map<String, dynamic> step) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            step['animation'],
            width: 250,
            height: 250,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 40),
          Text(
            step['title'],
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            step['description'],
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
