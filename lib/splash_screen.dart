import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'main.dart'; // Импортируйте main.dart для доступа к MyHomePage

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      // Убедитесь, что у вас есть конструктор MyHomePage, который не требует обязательных аргументов,
      // или модифицируйте следующую строку в соответствии с требуемыми параметрами.
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => MyHomePage(
                    title: '',
                  )));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
            'assets/animations/zastavka.json'), // Путь к вашему ассету Lottie
      ),
    );
  }
}
