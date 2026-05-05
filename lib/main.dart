import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'screens/cart_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/order_success_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'FluxShop',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.welcome,
        routes: {
          AppRoutes.welcome: (_) => const WelcomeScreen(),
          AppRoutes.login: (_) => LoginScreen.init(),
          AppRoutes.register: (_) => RegisterScreen.init(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.productDetail: (_) => const ProductDetailScreen(),
          AppRoutes.cart: (_) => const CartScreen(),
          AppRoutes.orderSuccess: (_) => const OrderSuccessScreen(),
          AppRoutes.profile: (_) => const ProfileScreen(),
          AppRoutes.editProfile: (_) => EditProfileScreen.init(),
        },
      ),
    );
  }
}
