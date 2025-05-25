import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asistente de Voz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainAssistantScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de la app
            Icon(Icons.mic, size: 100, color: Colors.white),
            const SizedBox(height: 30),
            // Animación de carga
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class MainAssistantScreen extends StatefulWidget {
  const MainAssistantScreen({super.key});

  @override
  State<MainAssistantScreen> createState() => _MainAssistantScreenState();
}

class _MainAssistantScreenState extends State<MainAssistantScreen> {
  final PageController _controller = PageController(initialPage: 1);
  int _currentPage = 1;

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _goToPage(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: _onPageChanged,
            children: const [
              SettingsScreen(),
              VoiceScreen(),
              ChatScreen(),
            ],
          ),
          // Indicador superior de pantallas (más abajo para no tapar títulos)
          Positioned(
            top: 80, // antes 32, ahora más abajo
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ScreenIndicator(
                      icon: Icons.settings,
                      label: 'Config',
                      selected: _currentPage == 0,
                      onTap: () => _goToPage(0),
                    ),
                    const SizedBox(width: 16),
                    _ScreenIndicator(
                      icon: Icons.mic,
                      label: 'Voz',
                      selected: _currentPage == 1,
                      onTap: () => _goToPage(1),
                    ),
                    const SizedBox(width: 16),
                    _ScreenIndicator(
                      icon: Icons.chat,
                      label: 'Chat',
                      selected: _currentPage == 2,
                      onTap: () => _goToPage(2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreenIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ScreenIndicator({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurple.withOpacity(0.8) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.black54, size: 22),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black54,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> with SingleTickerProviderStateMixin {
  bool isListening = false;
  AnimationController? _controller;
  Animation<double>? _animation;
  bool _showHints = true;
  Timer? _hintTimer;
  bool _showLogMonitor = false;
  final List<String> _logs = [
    'App iniciada correctamente',
    'Micrófono encendido',
    'Usuario preguntó: ¿Cuál es el clima hoy?',
    'Asistente respondió: El clima es soleado',
    'Micrófono apagado',
    'Configuración cambiada: Volumen bajo',
  ];

  void _addLog(String log) {
    setState(() {
      _logs.add(log);
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeOutCubic),
    );
    _startHintTimer();
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    setState(() {
      _showHints = false;
    });
    _hintTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        _showHints = true;
      });
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _hintTimer?.cancel();
    super.dispose();
  }

  void _toggleMic() {
    setState(() {
      isListening = !isListening;
      if (isListening) {
        _controller?.forward(from: 0);
        _addLog('Micrófono encendido');
      } else {
        _controller?.reverse(from: 1);
        _addLog('Micrófono apagado');
      }
    });
  }



  void _onUserInteraction() {
    _startHintTimer();
  }

  @override
  Widget build(BuildContext context) {
    final Color micColor = isListening ? Colors.green : Colors.red;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _onUserInteraction,
      onPanDown: (_) => _onUserInteraction(),
      child: Stack(
        children: [
          // Fondo animado degradado
          AnimatedBuilder(
            animation: _animation ?? kAlwaysCompleteAnimation,
            builder: (context, child) {
              // Calcular la posición Y del micrófono
              final micYOffset = MediaQuery.of(context).size.height / 2 - 50;
              return CustomPaint(
                painter: MicBackgroundPainter(
                  progress: _animation?.value ?? 0.0,
                  color: micColor,
                  isListening: isListening,
                  micOffset: Offset(MediaQuery.of(context).size.width / 2, micYOffset + (_showLogMonitor ? 80 : 0)),
                ),
                child: Container(),
              );
            },
          ),
          // Flechas y texto de scroll (solo si _showHints)
          AnimatedOpacity(
            opacity: _showHints ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: IgnorePointer(
              ignoring: !_showHints,
              child: Stack(
                children: [
                  Positioned(
                    left: 10,
                    top: MediaQuery.of(context).size.height / 2 - 80 + (_showLogMonitor ? 80 : 0),
                    child: Column(
                      children: [
                        _ArrowScrollHint(
                          icon: Icons.arrow_back_ios,
                          text: '',
                          alignment: Alignment.centerLeft,
                          animateFrom: Alignment.centerLeft,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Configuraciones',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: MediaQuery.of(context).size.height / 2 - 80 + (_showLogMonitor ? 80 : 0),
                    child: Column(
                      children: [
                        _ArrowScrollHint(
                          icon: Icons.arrow_forward_ios,
                          text: '',
                          alignment: Alignment.centerRight,
                          animateFrom: Alignment.centerRight,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Chat',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Botón micrófono y botones adicionales
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _toggleMic,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: micColor.withOpacity(0.4),
                          blurRadius: 40 * (_animation!.value + 1),
                          spreadRadius: 10 * (_animation!.value + 1),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: micColor,
                      child: Icon(
                        isListening ? Icons.mic : Icons.mic_off,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isListening ? 'Escuchando...' : 'Toca para hablar',
                  style: const TextStyle(fontSize: 18, color: Colors.white, shadows: [Shadow(blurRadius: 8, color: Colors.black26)]),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _addLog('Botón "Repetir" presionado');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          ),
                          icon: const Icon(Icons.replay, color: Colors.white),
                          label: const Text('Repetir', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _addLog('Botón "Parar" presionado');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          ),
                          icon: const Icon(Icons.stop, color: Colors.white),
                          label: const Text('Parar', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Botón para mostrar/ocultar monitor de logs
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showLogMonitor = !_showLogMonitor;
                        _addLog(_showLogMonitor ? 'Monitor de logs abierto' : 'Monitor de logs cerrado');
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    icon: Icon(_showLogMonitor ? Icons.monitor : Icons.list_alt, color: Colors.white),
                    label: Text(_showLogMonitor ? 'Ocultar monitor' : 'Ver monitor', style: const TextStyle(color: Colors.white)),
                  ),
                ),
                // Monitor de logs animado
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: _showLogMonitor
                      ? Container(
                          key: const ValueKey('monitor'),
                          margin: const EdgeInsets.only(top: 18),
                          padding: const EdgeInsets.all(8),
                          width: 340,
                          height: 120, // Altura fija y menor
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.monitor_heart, color: Colors.greenAccent, size: 18),
                                  const SizedBox(width: 8),
                                  const Text('Monitor de logs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                              const Divider(color: Colors.white24, height: 12),
                              Expanded(
                                child: ListView.builder(
                                  reverse: true,
                                  itemCount: _logs.length,
                                  itemBuilder: (context, index) => Text(
                                    _logs[_logs.length - 1 - index],
                                    style: const TextStyle(color: Colors.white, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          // ...existing code...
        ],
      ),
    );
  }
}

class _ArrowScrollHint extends StatefulWidget {
  final IconData icon;
  final String text;
  final Alignment alignment;
  final Alignment animateFrom;
  const _ArrowScrollHint({required this.icon, required this.text, required this.alignment, required this.animateFrom});

  @override
  State<_ArrowScrollHint> createState() => _ArrowScrollHintState();
}

class _ArrowScrollHintState extends State<_ArrowScrollHint> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _offsetAnimation = Tween<Offset>(
      begin: widget.alignment == Alignment.centerLeft ? const Offset(-0.2, 0) : const Offset(0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.alignment == Alignment.centerLeft
            ? [
                Icon(widget.icon, color: Colors.white, size: 28),
                const SizedBox(width: 4),
                Text(widget.text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ]
            : [
                Text(widget.text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Icon(widget.icon, color: Colors.white, size: 28),
              ],
      ),
    );
  }
}

class MicBackgroundPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isListening;
  final Offset? micOffset;
  MicBackgroundPainter({required this.progress, required this.color, required this.isListening, this.micOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final center = micOffset ?? Offset(size.width / 2, size.height / 2);
    final double maxRadius = size.width * 0.7;
    final double radius = progress * maxRadius;
    final gradient = RadialGradient(
      colors: [
        color.withOpacity(0.7),
        Colors.white.withOpacity(0.7),
        Colors.white.withOpacity(0.0),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    if (progress > 0) {
      canvas.drawCircle(center, radius, paint);
    }
    // Fondo base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = color.withOpacity(0.2),
    );
  }

  @override
  bool shouldRepaint(covariant MicBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.isListening != isListening || oldDelegate.micOffset != micOffset;
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 80.0), // más espacio para el indicador
        child: ListView(
          children: const [
            SizedBox(height: 16), // Espacio extra antes del primer elemento
            ListTile(
              leading: Icon(Icons.language),
              title: Text('Idioma'),
              subtitle: Text('Español'),
            ),
            ListTile(
              leading: Icon(Icons.volume_up),
              title: Text('Volumen'),
              subtitle: Text('Alto'),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Acerca de'),
              subtitle: Text('Asistente de Voz v1.0'),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 80.0), // más espacio para el indicador
        child: Column(
          children: [
            const SizedBox(height: 16), // Espacio extra antes del primer mensaje
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ChatBubble(text: 'Hola, ¿en qué puedo ayudarte?'),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ChatBubble(text: '¿Cuál es el clima hoy?'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  const ChatBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(text),
    );
  }
}

