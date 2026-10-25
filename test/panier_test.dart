import 'package:flutter_test/flutter_test.dart';
import 'package:tp_catalogue/data/catalogue.dart';
import 'package:tp_catalogue/models/panier.dart';

void main() {
  final formationFlutter = catalogue.firstWhere(
    (formation) => formation.id == 'flutter',
  );

  final formationWeb = catalogue.firstWhere(
    (formation) => formation.id == 'web',
  );

  test('Un panier neuf est vide', () {
    final panier = Panier();
    addTearDown(panier.dispose);

    expect(panier.estVide, isTrue);
    expect(panier.nombre, 0);
    expect(panier.totalHeures, 0);
    expect(panier.totalPrix, 0);
  });

  test('Ajouter des modules calcule les bons totaux', () {
    final panier = Panier();
    addTearDown(panier.dispose);

    panier.definirModules(formationFlutter, {'flutter-1', 'flutter-3'});

    expect(panier.nombre, 2);
    expect(panier.totalHeures, 26);
    expect(panier.totalPrix, 260);
  });

  test('Modifier une formation conserve les autres formations', () {
    final panier = Panier();
    addTearDown(panier.dispose);

    panier.definirModules(formationFlutter, {'flutter-1', 'flutter-2'});

    panier.definirModules(formationWeb, {'web-1'});
    panier.definirModules(formationFlutter, {'flutter-4'});

    expect(panier.modulesDe(formationFlutter), {'flutter-4'});
    expect(panier.modulesDe(formationWeb), {'web-1'});
    expect(panier.nombre, 2);
    expect(panier.totalPrix, 170);
  });

  test('Annuler une suppression restaure la position et les totaux', () {
    final panier = Panier();
    addTearDown(panier.dispose);

    panier.definirModules(formationFlutter, {
      'flutter-1',
      'flutter-2',
      'flutter-3',
    });

    final element = panier.elements[1];
    final index = panier.retirer(element);

    expect(panier.nombre, 2);
    expect(panier.totalPrix, 260);

    panier.inserer(index, element);

    expect(panier.nombre, 3);
    expect(panier.elements[1].cle, 'flutter-2');
    expect(panier.totalPrix, 420);
  });

  test('Vider le panier réinitialise les totaux', () {
    final panier = Panier();
    addTearDown(panier.dispose);

    panier.definirModules(formationWeb, {'web-1', 'web-2'});
    panier.vider();

    expect(panier.estVide, isTrue);
    expect(panier.totalHeures, 0);
    expect(panier.totalPrix, 0);
  });

  test('Les modifications notifient les écouteurs', () {
    final panier = Panier();
    addTearDown(panier.dispose);

    var notifications = 0;
    panier.addListener(() => notifications++);

    panier.definirModules(formationWeb, {'web-1'});
    panier.vider();

    expect(notifications, 2);
  });
}
