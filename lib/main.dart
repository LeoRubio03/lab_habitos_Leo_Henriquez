import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 2 - Hábitos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const PanelHabitos(),
    );
  }
}

class PanelHabitos extends StatefulWidget {
  const PanelHabitos({super.key});

  @override
  State<PanelHabitos> createState() => _PanelHabitosState();
}

class _PanelHabitosState extends State<PanelHabitos> {
  // --- Datos fijos ---
  final List<String> _habitos = const [
    'Beber 2 L de agua',
    'Leer 20 minutos',
    'Caminar 30 minutos',
    'Estudiar Flutter',
    'Dormir 8 horas',
  ];

  // --- Estado ---
  late List<bool> _cumplidos;
  int _meta = _metaInicial;
  bool _enfoque = false;
  String _nota = '';
  final TextEditingController _notaCtrl = TextEditingController();

  // --- Extensión opcional: Historial de días ---
  final List<int> _historial = [];

  static const int _metaInicial = 3;

  @override
  void initState() {
    super.initState();
    _cumplidos = List<bool>.filled(_habitos.length, false);
  }

  @override
  void dispose() {
    _notaCtrl.dispose();
    super.dispose();
  }

  // --- Getters derivados ---
  int get _totalCumplidos => _cumplidos.where((c) => c).length;

  double get _progreso =>
      _habitos.isEmpty ? 0 : _totalCumplidos / _habitos.length;

  bool get _metaAlcanzada => _totalCumplidos >= _meta;

  String get _mensaje {
    final p = (_progreso * 100).round();
    if (p == 0) return '¡Empecemos!';
    if (p < 50) return 'Buen inicio';
    if (p < 100) return '¡Vas muy bien!';
    return '¡Día completado!';
  }

  // --- Acciones de Cambio de Estado ---
  void _alternarHabito(int index) {
    setState(() {
      _cumplidos[index] = !_cumplidos[index];
    });
  }

  void _cambiarMeta(double v) {
    setState(() {
      _meta = v.round();
    });
  }

  void _alternarEnfoque(bool v) {
    setState(() {
      _enfoque = v;
    });
  }

  void _guardarNota() {
    setState(() {
      _nota = _notaCtrl.text.trim();
    });
  }

  void _reiniciarDia() {
    setState(() {
      // Registrar el total de cumplidos en el historial del día antes de borrar
      if (_totalCumplidos > 0) {
        _historial.add(_totalCumplidos);
      }

      _cumplidos = List<bool>.filled(_habitos.length, false);
      _meta = _metaInicial;
      _enfoque = false;
      _nota = '';
      _notaCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hábitos — $_totalCumplidos / ${_habitos.length}'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Progreso e Indicador
          LinearProgressIndicator(
            value: _progreso,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(_progreso * 100).round()}% completado',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                _mensaje,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _progreso == 1.0 ? Colors.green : Colors.black87,
                ),
              ),
            ],
          ),
          const Divider(height: 32),

          // 2. Control de Meta (Slider)
          Text(
            'Meta del día: $_meta hábitos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: _meta.toDouble(),
            min: 1,
            max: _habitos.length.toDouble(),
            divisions: _habitos.length - 1,
            label: '$_meta',
            onChanged: _cambiarMeta,
          ),
          if (_metaAlcanzada)
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: const Icon(Icons.star, color: Colors.amber),
                label: const Text('¡Meta alcanzada!'),
                backgroundColor: Colors.amber.shade50,
              ),
            ),
          const Divider(height: 32),

          // 3. Switch de Modo Enfoque
          SwitchListTile(
            title: const Text('Modo enfoque'),
            subtitle: const Text('Ocultar hábitos completados'),
            value: _enfoque,
            onChanged: _alternarEnfoque,
          ),
          const SizedBox(height: 8),

          // 4. Lista de Hábitos
          Text(
            'Lista de hábitos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...List.generate(_habitos.length, (i) {
            if (_enfoque && _cumplidos[i]) {
              return const SizedBox.shrink();
            }
            return CheckboxListTile(
              title: Text(
                _habitos[i],
                style: TextStyle(
                  decoration: _cumplidos[i]
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              value: _cumplidos[i],
              onChanged: (_) => _alternarHabito(i),
            );
          }),
          const Divider(height: 32),

          // 5. Nota del día
          Text(
            'Nota del día',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _notaCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Escribe una nota...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _guardarNota(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _guardarNota,
                child: const Text('Guardar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nota guardada:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(_nota.isEmpty ? 'Sin nota' : _nota),
                ],
              ),
            ),
          ),
          const Divider(height: 32),

          // 6. Extensión Opcional: Historial de Días
          Text(
            'Historial de días anteriores',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_historial.isEmpty)
            const Text(
              'Aún no hay días registrados en el historial.',
              style: TextStyle(color: Colors.grey),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: List.generate(_historial.length, (index) {
                return Chip(
                  avatar: const Icon(Icons.history, size: 16),
                  label: Text('Día ${index + 1}: ${_historial[index]} / ${_habitos.length}'),
                );
              }),
            ),
          const SizedBox(height: 24),

          // 7. Botón de Reiniciar
          OutlinedButton.icon(
            onPressed: _reiniciarDia,
            icon: const Icon(Icons.refresh),
            label: const Text('Reiniciar día'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}