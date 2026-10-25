import 'package:flutter/material.dart';

import '../models/formation.dart';
import '../models/panier.dart';

class DetailFormationScreen extends StatefulWidget {
  final Formation formation;
  final Panier panier;

  const DetailFormationScreen({
    super.key,
    required this.formation,
    required this.panier,
  });

  @override
  State<DetailFormationScreen> createState() => _DetailFormationScreenState();
}

class _DetailFormationScreenState extends State<DetailFormationScreen> {
  late final Set<String> _selection;

  Formation get formation => widget.formation;

  @override
  void initState() {
    super.initState();
    _selection = widget.panier.modulesDe(formation);
  }

  bool? get _etatTout {
    if (_selection.isEmpty) return false;
    if (_selection.length == formation.modules.length) return true;
    return null;
  }

  double get _sousTotal {
    return formation.modules
        .where((module) => _selection.contains(module.id))
        .fold<double>(0, (total, module) => total + module.prix);
  }

  void _basculerTout() {
    setState(() {
      if (_etatTout == true) {
        _selection.clear();
      } else {
        _selection.addAll(formation.modules.map((module) => module.id));
      }
    });
  }

  void _basculerModule(Module module, bool? coche) {
    setState(() {
      if (coche == true) {
        _selection.add(module.id);
      } else {
        _selection.remove(module.id);
      }
    });
  }

  void _valider() {
    final messenger = ScaffoldMessenger.of(context);

    widget.panier.definirModules(formation, _selection);
    Navigator.pop(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _selection.isEmpty
                ? 'Formation retirée du panier'
                : '${_selection.length} module(s) dans le panier',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final texte = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(formation.titre, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: formation.couleur.withAlpha(38),
                        child: Icon(
                          formation.icone,
                          color: formation.couleur,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(formation.titre, style: texte.titleMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(formation.description),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text(formation.niveau)),
                      Chip(label: Text('${formation.dureeTotale} h')),
                      Chip(label: Text('${formation.modules.length} modules')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Modules', style: texte.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                CheckboxListTile(
                  tristate: true,
                  value: _etatTout,
                  onChanged: (_) => _basculerTout(),
                  title: const Text('Tout sélectionner'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const Divider(height: 1),
                ...formation.modules.map(
                  (module) => CheckboxListTile(
                    value: _selection.contains(module.id),
                    onChanged: (valeur) {
                      _basculerModule(module, valeur);
                    },
                    title: Text(module.titre),
                    subtitle: Text(
                      '${module.heures} h • ${formatPrix(module.prix)}',
                    ),
                    secondary: Icon(
                      Icons.menu_book_outlined,
                      color: formation.couleur,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sous-total'),
                  Text(formatPrix(_sousTotal), style: texte.titleMedium),
                ],
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _valider,
                icon: const Icon(Icons.add_shopping_cart),
                label: Text('Mettre à jour le panier (${_selection.length})'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
