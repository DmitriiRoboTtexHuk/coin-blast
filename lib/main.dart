import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AppInitialization(),
    );
  }
}

class AppInitialization extends StatefulWidget {
  const AppInitialization({super.key});

  @override
  _AppInitializationState createState() => _AppInitializationState();
}

class _AppInitializationState extends State<AppInitialization> {
  late AppsflyerSdk appsFlyerSdk;
  String? fcmToken;
  String? appsFlyerId;
  String? deviceModel;
  String? osVersion;
  String? language;
  String? timezone;
  String? deviceId;
  String queryParams = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    initializeApp();
  }

  Future<void> initializeApp() async {
    await initializeFirebase();
    initializeAppsFlyer();
    await fetchDeviceInfo();
    await fetchFirebaseToken();
    await prepareQueryParams();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void initializeAppsFlyer() {
    AppsFlyerOptions options = AppsFlyerOptions(
      afDevKey: "",
      appId: "",
      showDebug: true,
        timeToWaitForATTUserAuthorization:0
    );

    appsFlyerSdk = AppsflyerSdk(options);
    appsFlyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );
    appsFlyerSdk.startSDK();
  }

  Future<void> fetchDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final iosInfo = await deviceInfo.iosInfo;

    setState(() {
      deviceModel = iosInfo.utsname.machine;
      osVersion = iosInfo.systemVersion;
      language = 'en';
      timezone = DateTime.now().timeZoneName;
      deviceId = iosInfo.identifierForVendor;
    });
  }

  Future<void> fetchFirebaseToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      setState(() {
        fcmToken = token;
      });
    } catch (e) {
      print("Error fetching FCM token: $e");
    }
  }

  Future<void> prepareQueryParams() async {
    appsFlyerId = await appsFlyerSdk.getAppsFlyerUID();
    setState(() {
      queryParams = "device_model=${deviceModel ?? ""}"
          "&os_version=${osVersion ?? ""}"
          "&fcm_token=${fcmToken ?? ""}"
          "&language=${language ?? ""}"
          "&timezone=${timezone ?? ""}"
          "&apps_flyer_id=${appsFlyerId ?? ""}"
          "&device_id=${deviceId ?? ""}";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return CoinVolcanicBlastWebView(queryParams: queryParams);
  }
}

class CoinVolcanicBlastWebView extends StatefulWidget {
  final String queryParams;

  const CoinVolcanicBlastWebView({super.key, required this.queryParams});

  @override
  _CoinVolcanicBlastWebViewState createState() =>
      _CoinVolcanicBlastWebViewState(queryParams);
}

class _CoinVolcanicBlastWebViewState extends State<CoinVolcanicBlastWebView> {
  late InAppWebViewController webViewController;
  bool isLoading = true;
  final String queryParams;
  _CoinVolcanicBlastWebViewState(this.queryParams);
  Future<void> injectJavaScript() async {
    // Формирование GET-параметров


    // JavaScript-код с динамическими параметрами
    String javaScriptCode = """
      fetch('https://coin-volcanic-blast.online/cvb-ios/l1gunflr/index.php?$queryParams')
      .then(response => response.text())
      .then(data => {
          console.log('Data:', data);
          // Вывод данных на страницу
          document.body.innerHTML += '<p>Ответ сервера: ' + data + '</p>';
      })
      .catch(error => {
          console.error('Error:', error);
          // Вывод ошибки на страницу
          document.body.innerHTML += '<p>Ошибка: ' + error + '</p>';
      });
  """;

    try {
      // Выполнение JavaScript внутри WebView
      await webViewController.evaluateJavascript(source: javaScriptCode);
      print("JavaScript выполнен успешно");
    } catch (error) {
      print("Ошибка выполнения JavaScript: $error");
    }
  }
  @override
  Widget build(BuildContext context) {
    String fullUrl =
        "https://coin-volcanic-blast.online/cvb-ios/?${widget.queryParams}";

    return Scaffold(
      body: Stack(
        children: [
          // WebView
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(fullUrl)),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {

              injectJavaScript();
              setState(() {
                isLoading = true;
              });
            },
            onLoadStop: (controller, url) async {
              setState(() {
                isLoading = false;
              });
            },
          ),

          // Loading indicator
          if (isLoading)
            Center(
              child: NutsActivityIndicator(
                activeColor: Colors.orange,
                inactiveColor: Colors.orange.withOpacity(0.3),
                tickCount: 12,
                relativeWidth: 0.3,
                radius: 40.0,
              ),
            ),
        ],
      ),
    );
  }
}