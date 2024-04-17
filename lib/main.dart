import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'history_page.dart'; // Убедитесь, что указан правильный путь к файлу

void main() => runApp(const MyApp());

const appTitle = 'My Scanner Demo';
const buttonScan = 'СКАНИРОВАТЬ';
const tooltipHistory = 'Показать историю сканирований';
const scanButtonColor = '#28386a';
const cancelButtonText = 'Cancel';
const scanTitle = 'ОТСКАНИРУЙТЕ ШТРИХ КОД';
const scannedCodesKey =
    'scannedCodes'; // Ключ для хранения истории сканирований

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MyHomePage(title: scanTitle)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Lottie.asset('assets/animations/zastavka.json')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> scannedCodes = [];

  @override
  void initState() {
    super.initState();
    _loadScannedCodes();
  }

  Future<void> _loadScannedCodes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      scannedCodes = prefs.getStringList(scannedCodesKey) ?? [];
    });
  }

  Future<void> _saveScannedCodes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(scannedCodesKey, scannedCodes);
  }

  Future<void> _scanCode() async {
    try {
      String scanRes = await FlutterBarcodeScanner.scanBarcode(
          scanButtonColor, cancelButtonText, true, ScanMode.QR);
      if (!mounted || scanRes == '-1') return;
      setState(() {
        scannedCodes.add(scanRes);
      });
      _saveScannedCodes();
    } catch (e) {
      print("Ошибка при сканировании: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: scannedCodes.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(scannedCodes[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      scannedCodes.removeAt(index);
                    });
                    _saveScannedCodes();
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: _scanCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD2DEE7),
              ),
              child: const Text(buttonScan),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoryPage(
                scannedCodes: scannedCodes,
                onDelete: () {
                  setState(() {
                    scannedCodes.clear();
                  });
                  _saveScannedCodes();
                },
              ),
            ),
          );
        },
        tooltip: tooltipHistory,
        child: const Icon(Icons.history),
      ),
    );
  }
}
