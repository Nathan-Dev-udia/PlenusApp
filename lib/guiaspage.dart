import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Para formatar a data

class GuiaPage extends StatelessWidget {
  final Map<String, dynamic> guia;
  final VoidCallback? onStatusChanged;

  const GuiaPage({super.key, required this.guia, this.onStatusChanged});

  Future<void> _abrirLink(String url, BuildContext context) async {
    if (!url.startsWith("https://www.")) {
      url = url.replaceFirst("https://", "https://www.");
    }

    final Uri uri = Uri.parse(url);

    try {
      final bool aberto = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!aberto) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao abrir o link: $e')));
      }
    }
  }

  Future<void> _atualizarStatusGuia(
    BuildContext context,
    bool novaSituacao,
  ) async {
    try {
      final ref = FirebaseDatabase.instance.ref(
        "usuarios/${FirebaseAuth.instance.currentUser!.uid}/guias/${guia["id"]}",
      );

      await ref.update({"concluida": novaSituacao});

      if (onStatusChanged != null) onStatusChanged!();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              novaSituacao
                  ? "Guia marcada como concluída ✅"
                  : "Guia desmarcada como concluída ↩️",
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao atualizar: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Status bar escura ao abrir a página
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF6C396D),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final bool isConcluida = guia["concluida"] == true;

    // Preparar a data de vencimento
    String dataVenc = "Esta guia não possui data de vencimento";
    if (guia.containsKey("data_venc")) {
      final v = guia["data_venc"];
      if (v != null && v.toString().trim().isNotEmpty) {
        try {
          final parsedDate = DateTime.parse(v.toString());
          dataVenc = DateFormat('dd/MM/yyyy').format(parsedDate);
        } catch (e) {
          // Caso a data venha em formato estranho
          dataVenc = v.toString();
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          guia["titulo"] ?? "-",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // título branco
          ),
        ),
        backgroundColor: const Color(0xFF6C396D),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de Data de Vencimento
            FractionallySizedBox(
              widthFactor: 0.8,
              alignment: Alignment.centerLeft,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(
                    Icons.calendar_today,
                    color: Colors.purple,
                  ),
                  title: Text(
                    dataVenc,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("Data de vencimento"),
                ),
              ),
            ),
            // Card de Instruções
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SelectableText(
                  "📝 Instruções: ${guia["instrucoes"] ?? "-"}",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Botão Abrir Pasta
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C396D),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _abrirLink(guia["url"] ?? "", context),
                icon: const Icon(Icons.folder_open, color: Colors.white),
                label: const Text(
                  "Abrir Pasta",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Botão Concluir / Desmarcar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isConcluida ? Colors.orange : Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _atualizarStatusGuia(context, !isConcluida),
                icon: Icon(
                  isConcluida ? Icons.undo : Icons.check_circle_outline,
                  color: Colors.white,
                ),
                label: Text(
                  isConcluida
                      ? "Desmarcar como concluída"
                      : "Marcar como concluída",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
