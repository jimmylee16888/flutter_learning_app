import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_learning_app/services/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../utils/tip_prompter.dart';

class TipGate extends StatefulWidget {
  const TipGate({
    super.key,
    required this.child,
    required this.idTokenProvider,
    required this.clientId,
    required this.meId,
    required this.meNameLocal,
  });

  final Widget child;
  final Future<String?> Function() idTokenProvider;
  final String clientId;
  final String meId;
  final String meNameLocal;

  @override
  State<TipGate> createState() => _TipGateState();
}

class _TipGateState extends State<TipGate> {
  bool _done = false;

  @override
  void initState() {
    super.initState();
    // 等第一幀出來再顯示對話框，避免 build 時期呼叫 showDialog
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final api = SocialApi(
        meId: widget.meId,
        meName: widget.meNameLocal,
        idTokenProvider: widget.idTokenProvider,
        clientId: widget.clientId,
        clientAliasProvider: () async => null,
      );
      await TipPrompter.showIfNeeded(context, api: api);
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
