import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/hive_contants.dart';
import 'package:medyo/services/audio_service.dart';
import 'package:medyo/utils/routes.dart';

import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
  showFlutterNotification(message);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  debugPrint('Setting up Flutter Local Notifications');
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }

  // Define the Android notification channel
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize the Flutter Local Notifications plugin
  const initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Request notification permission on Android 13+
  if (Platform.isAndroid) {
    debugPrint('Android 13+ detected');
    final granted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    if (granted != null && !granted) {
      print('Notification permission denied by the user.');
      return; // Exit if permission is denied
    } else {
      print('Notification permission granted by the user.');
    }
  } else {
    print('Android 13+ not detected');
  }

  // Create the Android Notification Channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Set iOS foreground notification presentation options
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  final RemoteNotification? notification = message.notification;
  final AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          icon: '@drawable/ic_launcher',
        ),
      ),
    );
  }
}

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else if (Platform.isIOS) {
    await Firebase.initializeApp();
  }
  await setupFlutterNotifications();
  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((event) {
    showFlutterNotification(event);
  });

  if (!kIsWeb) {
    await setupFlutterNotifications();
  }
  try {
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('Token : $token');
  } catch (e) {
    debugPrint('Failed to get FCM token: $e');
  }
  await Hive.initFlutter();
  await Hive.openBox(AppHSC.appSettingsBox);
  await Hive.openBox(AppHSC.authBox);
  await Hive.openBox(AppHSC.userBox);
  await Hive.openBox(AppHSC.loginInfoBox);
  await Hive.openBox(AppHSC.appBox);
  await Hive.openBox(AppHSC.recentlyPlayedBox);
  await Hive.openBox(AppHSC.continueListeningBox);
  await Hive.openBox(AppHSC.playerPrefsBox);

  HttpOverrides.global = MyHttpOverrides();

  runApp(
    ProviderScope(
      child: EasyLocalization(
        path: 'assets/translations',
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('tr', 'CY'),
          Locale('ar', 'SA')
        ],
        fallbackLocale: const Locale('en', 'US'),
        child: const MyApp(),
      ),
    ),
  );
  MobileAds.instance.initialize();
  RequestConfiguration configuration =
      RequestConfiguration(testDeviceIds: ['4D6A48E10FFBA2457C2BF4E8A3EAE1A7']);
  MobileAds.instance.updateRequestConfiguration(configuration);
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print("State $state");
    if (state == AppLifecycleState.paused) {
      // The app is going into the background or being terminated.
      // Stop the audio playback here.
      // Call your audio service stop method or pause method, depending on your implementation.
      print("App is in Background");
      // final audio = ref.watch(audioServiceProvider);
      // audio!.play();
    } else if (state == AppLifecycleState.resumed) {
      print("App is in Foreground");
      // The app is back to the foreground.
      // If you paused the audio, you can resume it here.
      // Call your audio service resume method, if applicable.
    } else if (state == AppLifecycleState.detached) {
      print("App is in detached");
      final audio = ref.watch(audioServiceProvider);
      audio!.stop();

      await AudioPlayer.clearAssetCache();
      // await AudioPlayer.clearAssetCache();

      await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      // await DefaultCacheManager().emptyCache();
      // WidgetsBinding.instance.removeObserver(this);
    }
  }

//if (state == AppLifecycleState.paused) { audio!.play(); } else if (state == AppLifecycleState.resumed) { audio!.play(); } else { audio!.stop(); SystemNavigator.pop(); }

  @override
  void initState() {
    super.initState();
    print("ON INIT");
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    print("ON disponse");
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(audioServiceProvider);
    return ScreenUtilInit(
        designSize: const Size(390, 844), // XD Design Size
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return ValueListenableBuilder(
              valueListenable: Hive.box(AppHSC.appBox).listenable(),
              builder: (context, Box box, _) {
                int? savedColorValue = box.get('saved_color');
                if (savedColorValue != null) {
                  AppColors.darkTeal = Color(savedColorValue);
                }
                return MaterialApp(
                  title: 'Maditam',
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  theme: ThemeData(
                    fontFamily: "Plus Jakarta Sans",
                    textSelectionTheme: const TextSelectionThemeData(
                        cursorColor: AppColors.lightGeay),
                  ),
                  onGenerateRoute: (settings) => generatedRoutes(settings),
                  initialRoute: Routes.splash,
                  builder: EasyLoading.init(),
                );
              });
        });
  }
}

// class MyApp extends ConsumerWidget with WidgetsBindingObserver {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     ref.watch(audioServiceProvider);
//     return ScreenUtilInit(
//         designSize: const Size(390, 844), // XD Design Size
//         minTextAdapt: true,
//         splitScreenMode: true,
//         builder: (context, child) {
//           return MaterialApp(
//             title: 'Maditam',
//             // debugShowCheckedModeBanner: false,
//             localizationsDelegates: context.localizationDelegates,
//             supportedLocales: context.supportedLocales,
//             locale: context.locale,
//             theme: ThemeData(
//               fontFamily: "Open Sans",
//               textSelectionTheme: const TextSelectionThemeData(
//                   cursorColor: AppColors.lightGeay),
//             ),
//             onGenerateRoute: (settings) => generatedRoutes(settings),
//             initialRoute: Routes.splash,
//             builder: EasyLoading.init(),
//           );
//         });
//   }
// }
