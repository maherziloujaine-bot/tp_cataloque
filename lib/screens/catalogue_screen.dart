import 'package:flutter/material.dart';

import '../data/catalogue.dart';
import '../models/formation.dart';
import '../models/panier.dart';
import '../widgets/formation_card.dart';
import 'detail_formation_screen.dart';
import 'panier_screen.dart';

class CatalogueScreen extends StatefulWidget {
  final Panier panier;

  const CatalogueScreen({super.key, required this.panier});

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  bool _enGrille = true;
  String _recherche = '';

  List<Formation> get _formationsFiltrees {
    final recherche = _recherche.trim().toLowerCase();

    if (recherche.isEmpty) return catalogue;

    return catalogue.where((formation) {
      return formation.titre.toLowerCase().contains(recherche) ||
          formation.niveau.toLowerCase().contains(recherche);
    }).toList();
  }

  void _ouvrirDetail(Formation formation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DetailFormationScreen(formation: formation, panier: widget.panier),
      ),
    );
  }

  void _ouvrirPanier() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PanierScreen(panier: widget.panier)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue des formations'),
        actions: [
          IconButton(
            tooltip: _enGrille ? 'Afficher en liste' : 'Afficher en grille',
            icon: Icon(_enGrille ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() => _enGrille = !_enGrille);
            },
          ),
          ListenableBuilder(
            listenable: widget.panier,
            builder: (context, child) {
              return IconButton(
                tooltip: 'Mon panier',
                onPressed: _ouvrirPanier,
                icon: Badge(
                  isLabelVisible: widget.panier.nombre > 0,
                  label: Text('${widget.panier.nombre}'),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher une formation…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (valeur) {
                setState(() => _recherche = valeur);
              },
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: widget.panier,
              builder: (context, child) {
                final formations = _formationsFiltrees;

                if (formations.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Aucune formation ne correspond à votre recherche',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return _enGrille ? _grille(formations) : _liste(formations);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _grille(List<Formation> formations) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: formations.length,
      itemBuilder: (context, index) {
        final formation = formations[index];

        return FormationCard(
          formation: formation,
          modulesChoisis: widget.panier.modulesDe(formation).length,
          onTap: () => _ouvrirDetail(formation),
        );
      },
    );
  }

  Widget _liste(List<Formation> formations) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: formations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final formation = formations[index];
        final choisis = widget.panier.modulesDe(formation).length;

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: formation.couleur.withAlpha(38),
              child: Icon(formation.icone, color: formation.couleur),
            ),
            title: Text(formation.titre),
            subtitle: Text(
              '${formation.niveau} • ${formation.dureeTotale} h'
              '${choisis > 0 ? '\n✓ $choisis module(s) choisi(s)' : ''}',
            ),
            isThreeLine: choisis > 0,
            trailing: Text(formatPrix(formation.prixTotal)),
            onTap: () => _ouvrirDetail(formation),
          ),
        );
      },
    );
  }
}
