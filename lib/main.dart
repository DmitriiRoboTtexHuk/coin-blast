import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:CoinVolcanicBlastWebView(),
    );
  }
}



class CoinVolcanicBlastWebView extends StatefulWidget {
  @override
  _CoinVolcanicBlastWebViewState createState() =>
      _CoinVolcanicBlastWebViewState();
}

class _CoinVolcanicBlastWebViewState extends State<CoinVolcanicBlastWebView> {
  late InAppWebViewController webViewController;
  bool isLoading = true; // Переменная для состояния загрузки

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
          // WebView
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri("https://coin-volcanic-blast.online/cvb-ios/"),
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                isLoading = true; // Показываем индикатор загрузки
              });
            },
            onLoadStop: (controller, url) async {
              setState(() {
                isLoading = false; // Скрываем индикатор загрузки
              });
            },
          ),

          // Индикатор загрузки
          if (isLoading)
            Center(
              child: NutsActivityIndicator(
                activeColor: Colors.orange,
                inactiveColor: Colors.orange.withOpacity(0.3),
                tickCount: 12,
                relativeWidth: 0.3,
                radius: 40.0, // Размер индикатора
              ),
            ),
        ],
      ),
    );
  }
}