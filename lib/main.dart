import 'package:flutter/material.dart';
import 'features/pages/sales_dashboard_page.dart';

void main() => runApp(const DashboardApp());

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Dashboard Web App',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: const SalesDashboardPage(),
  );
}
