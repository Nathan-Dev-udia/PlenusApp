import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'guiaspage.dart';
import 'package:flutter/services.dart';

// Certifique-se de ter um RouteObserver global no main.dart
import 'main.dart'; // aqui é só pra referência do routeObserver

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, RouteAware {
  final user = FirebaseAuth.instance.currentUser;
  String nome = "";
  String cnpj = "";
  List<Map<String, dynamic>> guiasPendentes = [];
  List<Map<String, dynamic>> guiasConcluidas = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
    _loadGuias();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Registrar rota no RouteObserver
    routeObserver.subscribe(this, ModalRoute.of(context)!);

    // Força status bar inicial
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Chamado quando voltamos de outra página
  @override
  void didPopNext() {
    // Garante que a UI já tenha sido reconstruída antes de aplicar a status bar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
      );
    });
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    final ref = FirebaseDatabase.instance.ref("usuarios/${user!.uid}");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map;
      setState(() {
        nome = data["nome"] ?? "Sem nome";
        cnpj = data["cnpj"] ?? "-";
      });
    }
  }

  Future<void> _loadGuias() async {
    if (user == null) return;
    final ref = FirebaseDatabase.instance.ref("usuarios/${user!.uid}/guias");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map;
      final pendentes = <Map<String, dynamic>>[];
      final concluidas = <Map<String, dynamic>>[];

      for (var e in data.entries) {
        final guiaData = e.value;
        if (guiaData is Map) {
          final guia = {
            "id": e.key,
            "titulo": guiaData["titulo"] ?? "Sem título",
            "data_venc": guiaData["data venc"] ?? "-",
            "instrucoes": guiaData["instrucoes"] ?? "-",
            "url": guiaData["url"] ?? "",
            "concluida": guiaData["concluida"] ?? false,
            "data_postagem": guiaData["data_postagem"],
          };
          if (guia["concluida"] == true) {
            concluidas.add(guia);
          } else {
            pendentes.add(guia);
          }
        }
      }

      pendentes.sort(
        (a, b) => _converterData(
          b["data_postagem"],
        ).compareTo(_converterData(a["data_postagem"])),
      );
      concluidas.sort(
        (a, b) => _converterData(
          b["data_postagem"],
        ).compareTo(_converterData(a["data_postagem"])),
      );

      setState(() {
        guiasPendentes = pendentes;
        guiasConcluidas = concluidas;
      });
    }
  }

  DateTime _converterData(dynamic data) {
    try {
      if (data is DateTime) return data;
      if (data is int) return DateTime.fromMillisecondsSinceEpoch(data);
      if (data is String) return DateTime.tryParse(data) ?? DateTime.now();
      if (data is Map && data.containsKey("seconds")) {
        return DateTime.fromMillisecondsSinceEpoch(data["seconds"] * 1000);
      }
      return DateTime.now();
    } catch (_) {
      return DateTime.now();
    }
  }

  String _formatarData(dynamic data) {
    final date = _converterData(data);
    return DateFormat("dd/MM/yyyy 'às' HH:mm").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // HEADER com logo + boas-vindas
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
            child: Row(
              children: [
                Image.asset(
                  "assets/images/imgcrop.png",
                  width: 95,
                  height: 95,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Bem-vindo,",
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                    Text(
                      nome,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/');
                    }
                  },
                ),
              ],
            ),
          ),
          // Barra de tabs
          Material(
            color: const Color(0xFF6C396D),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: "Pendentes", icon: Icon(Icons.folder_open)),
                Tab(text: "Concluídas", icon: Icon(Icons.check_circle)),
              ],
            ),
          ),
          // Conteúdo das guias
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGuiasList(guiasPendentes, false),
                _buildGuiasList(guiasConcluidas, true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuiasList(List<Map<String, dynamic>> guias, bool concluida) {
    if (guias.isEmpty) {
      return const Center(
        child: Text(
          "Nenhuma guia disponível.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: guias.length,
      itemBuilder: (context, index) {
        final guia = guias[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          color: const Color.fromARGB(255, 84, 43, 100).withAlpha(180),
          child: ListTile(
            leading: Icon(
              Icons.picture_as_pdf,
              color: concluida ? Colors.green : Colors.red,
              size: 36,
            ),
            title: Text(
              guia["titulo"],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              "📅 Postada em: ${_formatarData(guia["data_postagem"])}",
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      GuiaPage(guia: guia, onStatusChanged: _loadGuias),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
