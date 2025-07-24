import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import './service/local_push_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import './screens/home_screen.dart';
import './screens/auth/login_screen.dart';
import './screens/gold_rate/gold_rate.dart';
import './screens/slider/slider_view.dart';
import './screens/customer/customer_screen.dart';
import './screens/customer/create_customer_screen.dart';
import './screens/customer/update_customer.dart';
import './screens/customer/customer_view.dart';
import './screens/customer/pay_amount.dart';
import './screens/customer/purchase_amount.dart';
import './screens/staff/create_staff_screen.dart';
import './screens/staff/staff_list_screen.dart';
import './screens/auth/password_change_screen.dart';
import './screens/products/add_product_screen.dart';
import './screens/products/product_list_screen.dart';
import './screens/products/update_product_screen.dart';
import './providers/slider.dart' as slid;
import './providers/goldrate.dart';
import './providers/user.dart';
import './providers/transaction.dart' as trans;
import './providers/staff.dart';
import './providers/product.dart';
import './providers/category.dart';
import './providers/collections.dart';
import './screens/permission_message.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/cmpService.dart';
import 'providers/paymentBill.dart';
import 'providers/storage_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  LocalNotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  late bool _checkValue;

  @override
  void didChangeDependencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _checkValue = prefs.containsKey('staff');
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Staff(),
        ),
        ChangeNotifierProvider(
          create: (_) => User(),
        ),
        ChangeNotifierProvider(
          create: (_) => Goldrate(),
        ),
        ChangeNotifierProvider(
          create: (_) => trans.TransactionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => slid.SliderProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => Product(),
        ),
        ChangeNotifierProvider(
          create: (_) => Category(),
        ),
        ChangeNotifierProvider(
          create: (_) => Collection(),
        ),
        ChangeNotifierProvider(
          create: (_) => Storage(),
        ),
        ChangeNotifierProvider(create: (_) => PaymentBillProvider()),
        ChangeNotifierProvider(create: (_) => CompanyService())
      ],
      child: MaterialApp(
          title: 'Nambiyath God & Diamonds Gold',
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            primarySwatch: Colors.blueGrey,
            primaryColor: Color(0xFFdad6d7),
            // accentColor: Color(0xFFfacc88),
            fontFamily: 'Lato',
            appBarTheme: AppBarTheme(
              color: Color(0xFFdad6d7), // Set the AppBar background color

              titleTextStyle: TextStyle(
                color: Color.fromARGB(
                    255, 255, 255, 255), // Set the AppBar title text color
                fontSize: 20, // Customize the font size if needed
              ),
              iconTheme: IconThemeData(
                color: const Color.fromARGB(
                    255, 255, 255, 255), // Set the AppBar icon color
              ),
            ),
          ),
          // localizationsDelegates: [
          //   GlobalMaterialLocalizations.delegate,
          //   GlobalWidgetsLocalizations.delegate,
          // ],
          // supportedLocales: [
          //   Locale('en'),
          // ],
          debugShowCheckedModeBanner: false,
          home: AnimatedSplashScreen(
            splash: Image.asset('assets/images/icon1.png'),

            nextScreen: LoginScreen(),
            // _checkValue == true ? HomeScreen() : LoginScreen(),
            // HomeScreen(),
            splashIconSize: 200,
            splashTransition: SplashTransition.scaleTransition,
            backgroundColor: Color(0xFFdad6d7),
            duration: 1000,
          ),
          routes: {
            LoginScreen.routeName: (ctx) => LoginScreen(),
            CustomerScreen.routeName: (ctx) => CustomerScreen(),
            CreateCustomerScreen.routeName: (ctx) => CreateCustomerScreen(),
            UpdateCustomerScreen.routeName: (ctx) => UpdateCustomerScreen(),
            CustomerViewScreen.routeName: (ctx) => CustomerViewScreen(),
            PayAmountScreen.routeName: (ctx) => PayAmountScreen(),
            PurchaseAmountScreen.routeName: (ctx) => PurchaseAmountScreen(),
            GoldRateScreen.routeName: (ctx) => GoldRateScreen(),
            ViewSlidersScreen.routeName: (ctx) => ViewSlidersScreen(),
            StaffListScreen.routeName: (ctx) => StaffListScreen(),
            // CreateStaffScreen.routeName: (ctx) => CreateStaffScreen(),
            PasswordChangeScreen.routeName: (ctx) => PasswordChangeScreen(),
            AddProductScreen.routeName: (ctx) => AddProductScreen(),
            ProductListScreen.routeName: (ctx) => ProductListScreen(),
            UpdateProductScreen.routeName: (ctx) => UpdateProductScreen(),
            PermissionMessage.routeName: (ctx) => PermissionMessage(),
          }),
    );
  }
}
