// lib/navigation.dart
import 'package:flutter/material.dart';

/// 全域 root Navigator，用來在任何地方開 dialog / push route。
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
