import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/service_locator.dart';

/// 全局服务提供者
/// 包装所有Provider到应用程序的根部
class AppProviders extends StatelessWidget {
  final Widget child;
  final ServiceLocator serviceLocator;

  const AppProviders({
    Key? key,
    required this.child,
    required this.serviceLocator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: serviceLocator.getProviders(),
      child: child,
    );
  }
}
