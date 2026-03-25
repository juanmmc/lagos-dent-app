import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/lagos_logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const String _whatsAppUrl = 'https://wa.me/59177003255';
  static const String _googleMapsUrl = 'https://maps.google.com/?q=-17.8111102911801, -63.16887781537168';

  static Future<void> _openExternalLink(
    BuildContext context,
    String rawUrl,
  ) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El enlace configurado no es valido.')),
      );
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Align(child: LagosLogo(size: 220)),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.push('/login/patient'),
                child: const Text('Ingresar como Paciente'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push('/login/doctor'),
                child: const Text('Ingresar como Doctor'),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: () => _openExternalLink(context, _whatsAppUrl),
                    icon: const Icon(Icons.chat_rounded),
                    label: const Text('WhatsApp'),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        _openExternalLink(context, _googleMapsUrl),
                    icon: const Icon(Icons.location_on_rounded),
                    label: const Text('Como llegar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
