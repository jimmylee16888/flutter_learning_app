// lib/widgets/tip_gate.dart
import 'package:flutter/material.dart';
import 'package:flutter_learning_app/services/services.dart'; // 有 TipService、BaseUrl
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
  final _tipService = const TipService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await widget.idTokenProvider();

      final url = _tipService.buildDailyUrl(
        clientId: widget.clientId,
        meId: widget.meId,
        meNameLocal: widget.meNameLocal,
        idToken: token,
        locale: Localizations.maybeLocaleOf(context),
        // 如需：appVersion / platform 也可一併帶過去
      );

      await TipPrompter.showIfNeeded(context, endpointUrl: url);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
