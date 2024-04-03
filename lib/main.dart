import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'history_page.dart'; // Проверьте правильный путь к файлу

void main() => runApp(MyApp());

const appTitle = 'My Scanner Demo';
const buttonScan = 'СКАНИРОВАТЬ';
const tooltipHistory = 'Показать историю сканирований';
const scanButtonColor = '#28386a';
const cancelButtonText = 'Cancel';
const scanTitle = 'ОТСКАНИРУЙТЕ ШТРИХ КОД';
const scannedCodesKey = 'scannedCodes'; // Ключ для хранения истории сканирований

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
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
    await Future.delayed(Duration(seconds: 3));
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MyHomePage(title: scanTitle)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Lottie.asset('assets/animations/zastavka.json')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
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
    String scanRes = await FlutterBarcodeScanner.scanBarcode(scanButtonColor, cancelButtonText, true, ScanMode.QR);
    if (!mounted || scanRes == '-1') return;
    setState(() {
      scannedCodes.add(scanRes);
    });
    _saveScannedCodes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
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
          ),
        ],
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
                  icon: Icon(Icons.delete),
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
              child: Text(buttonScan),
              style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 210, 222, 231)),
            ),
          ),
        ],
      ),
    );
  }
}