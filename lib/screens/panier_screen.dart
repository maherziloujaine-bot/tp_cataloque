import 'package:flutter/material.dart';

import '../models/formation.dart';
import '../models/panier.dart';

class PanierScreen extends StatelessWidget {
  final Panier panier;

  const PanierScreen({super.key, required this.panier});

  void _retirer(BuildContext context, ElementPanier element) {
    final index = panier.retirer(element);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('« ${element.module.titre} » retiré'),
          action: SnackBarAction(
            label: 'Annuler',
            onPressed: () => panier.inserer(index, element),
          ),
        ),
      );
  }

  Future<void> _vider(BuildContext context) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Vider le panier ?'),
        content: const Text('Tous les modules sélectionnés seront retirés.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Vider'),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      panier.vider();
    }
  }

  Future<void> _valider(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Inscription enregistrée'),
        content: Text(
          '${panier.nombre} module(s) • ${panier.totalHeures} h\n'
          'Montant : ${formatPrix(panier.totalPrix)}',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Terminer'),
          ),
        ],
      ),
    );

    panier.vider();

    if (context.mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: panier,
      builder: (context, child) {
        final elements = panier.elements;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mon panier'),
            actions: [
              IconButton(
                tooltip: 'Vider le panier',
                onPressed: panier.estVide ? null : () => _vider(context),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: panier.estVide
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.remove_shopping_cart_outlined,
                        size: 72,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      const Text('Votre panier est vide'),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Parcourir le catalogue'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: elements.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final element = elements[index];

                    return Dismissible(
                      key: ValueKey(element.cle),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Theme.of(context).colorScheme.error,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _retirer(context, element),
                      child: ListTile(
                        tileColor: Colors.white,
                        leading: CircleAvatar(
                          backgroundColor: element.formation.couleur.withAlpha(
                            38,
                          ),
                          child: Icon(
                            element.formation.icone,
                            color: element.formation.couleur,
                          ),
                        ),
                        title: Text(element.module.titre),
                        subtitle: Text(
                          '${element.formation.titre} • '
                          '${element.module.heures} h',
                        ),
                        trailing: Text(formatPrix(element.module.prix)),
                      ),
                    );
                  },
                ),
          bottomNavigationBar: panier.estVide
              ? null
              : Material(
                  elevation: 8,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Total (${panier.nombre} modules, '
                                  '${panier.totalHeures} h)',
                                ),
                              ),
                              Text(
                                formatPrix(panier.totalPrix),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () => _valider(context),
                            icon: const Icon(Icons.check),
                            label: const Text("Valider l'inscription"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
