import 'package:flutter/foundation.dart';

import 'formation.dart';

class ElementPanier {
  final Formation formation;
  final Module module;

  const ElementPanier(this.formation, this.module);

  String get cle => module.id;
}

class Panier extends ChangeNotifier {
  final List<ElementPanier> _elements = [];

  List<ElementPanier> get elements => List.unmodifiable(_elements);

  int get nombre => _elements.length;

  bool get estVide => _elements.isEmpty;

  int get totalHeures =>
      _elements.fold<int>(0, (total, e) => total + e.module.heures);

  double get totalPrix =>
      _elements.fold<double>(0, (total, e) => total + e.module.prix);

  bool contient(Module module) =>
      _elements.any((e) => e.module.id == module.id);

  Set<String> modulesDe(Formation formation) {
    return _elements
        .where((e) => e.formation.id == formation.id)
        .map((e) => e.module.id)
        .toSet();
  }

  void definirModules(Formation formation, Set<String> idsModules) {
    _elements.removeWhere((e) => e.formation.id == formation.id);

    for (final module in formation.modules) {
      if (idsModules.contains(module.id)) {
        _elements.add(ElementPanier(formation, module));
      }
    }

    notifyListeners();
  }

  int retirer(ElementPanier element) {
    final index = _elements.indexWhere((e) => e.cle == element.cle);

    if (index >= 0) {
      _elements.removeAt(index);
      notifyListeners();
    }

    return index;
  }

  void inserer(int index, ElementPanier element) {
    if (index < 0 || contient(element.module)) return;

    final position = index > _elements.length ? _elements.length : index;

    _elements.insert(position, element);
    notifyListeners();
  }

  void vider() {
    _elements.clear();
    notifyListeners();
  }
}
