import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/products/providers/product_provider.dart';
import 'features/products/screens/product_list_screen.dart';
import 'features/sales/providers/cart_provider.dart';
import 'features/sales/screens/pos_screen.dart';
import 'features/inventory_analytics/providers/report_provider.dart';
import 'features/inventory_analytics/screens/dahsboard_screen.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await NotificationService.init();
  } catch (e) {
    print("⚠️ Gagal Init Notifikasi: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: MaterialApp(
        title: 'WarungKu POS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        home: const MainNavigation(),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 1;
  final List<Widget> _screens = [
    const PosScreen(),
    const ProductListScreen(),
    const DashboardScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ProductProvider>(context, listen: false).fetchProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.point_of_sale), label: "Kasir"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Produk"),
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics), label: "Laporan"),
        ],
      ),
    );
  }
}
