import 'package:flutter/material.dart';
import 'dart:async';
import 'screens/admin_login_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/admin_room_first screen.dart';
import 'screens/sales_dashboard.dart';
import 'screens/splash_screen.dart';
import 'screens/admin_category_selection_screen.dart';
import 'screens/admin_device_list_screen.dart';
import 'services/storage_service.dart';
import 'screens/sales_rep_login.dart';
import 'screens/installation_engi_login.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/sales_generate_report.dart';
import 'screens/super_admin_dashboard.dart';
import 'screens/super_admin_institution_management.dart';
import 'screens/super_admin_login.dart';
import 'screens/super_admin_reports.dart';
import 'screens/super_admin_user_management.dart';
import 'screens/admin_institution_selection_screen.dart';
import 'screens/admindashboardfinal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SmartHomeApp());
}

class SmartHomeApp extends StatefulWidget {
  @override
  _SmartHomeAppState createState() => _SmartHomeAppState();
}

class _SmartHomeAppState extends State<SmartHomeApp> {
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    String? token = await StorageService.getToken();
    if (token != null) {
      String? userRole = await StorageService.getUserRole();
      setState(() {
        if (userRole == "super_admin") {
          _initialRoute = "/super_admin_dashboard";
        } else if (userRole == "admin") {
          _initialRoute = "/admin_login";
        } else if (userRole == "sales") {
          _initialRoute = "/sales_dashboard";
        } else {
          _initialRoute = "/customer_list";
        }
      });
    } else {
      setState(() {
        _initialRoute = "/role";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: _initialRoute ?? "/splash",

      routes: {
        '/splash': (context) => SplashScreen(),
        '/role': (context) => RoleSelectionScreen(),
        '/admin_login': (context) => AdminLoginScreen(),
        '/sales_login': (context) => SalesLoginScreen(),
        '/sales_dashboard': (context) => SalesDashboard(),
        '/engineer_login': (context) => EngineerLoginScreen(),
        '/sign_up': (context) => SignUpScreen(),
        '/forgot_password': (context) => ForgotPasswordScreen(),
        '/super_admin_dashboard': (context) => SuperAdminDashboard(),
        '/super_admin_login':(context)=> SuperAdminLoginScreen(),
        '/super_admin_user_management': (context) => SuperAdminUserManagement(),
        '/super_admin_institution_management': (context) =>
            SuperAdminInstitutionManagement(),
        '/super_admin_reports': (context) => SuperAdminReports(),
        '/admin_institution_selection': (context) =>
            AdminInstitutionSelectionScreen(),
        '/generate_report': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return GenerateReportScreen(
            customerId: args['customerId'],
            quotationId: args['quotationId'],
            roomDevices: args['roomDevices'],
            totalCost: args['totalCost'],
          );
        },
      },

      // ✅ Handle dynamic routes for institution, room & category selection
      onGenerateRoute: (settings) {
        if (settings.name == '/admin_dashboard') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => AdminDashboardScreen(
              institutionId: args['institutionId'],
            ),
          );
        }

        if (settings.name == '/category_selection') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => CategorySelectionScreen(
              institutionId: args['institutionId'],
            ),
          );
        }

        if (settings.name == '/device_list') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => DeviceListScreen(
              categoryId: args['categoryId'],
              categoryName: args['categoryName'],
            ),
          );
        }

        return null;
      },
    );
  }
}
