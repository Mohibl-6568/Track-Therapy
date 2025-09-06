import 'package:flutter/material.dart';
import 'homescreen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MaterialApp(home: HomeScreen())));
}
