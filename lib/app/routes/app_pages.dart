import 'package:get/get.dart';
import 'package:translator/views/history_view.dart';
import 'package:translator/views/home_view.dart';

class AppPages {
  static const initial = '/';

  static final routes = [
    GetPage(
      name: '/',
      page: () => const HomeView(),
    ),
    GetPage(
      name: '/history',
      page: () => const HistoryView(),
    ),
  ];
}