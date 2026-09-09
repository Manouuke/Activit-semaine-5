import 'package:flutter/material.dart';

import '../modele/redacteur.dart';
import '../services/database_manager.dart';


class RedacteurInterface extends StatefulWidget {
  const RedacteurInterface({super.key});

  @override
  State<RedacteurInterface> createState() => _RedacteurInterfaceState();
}

class _RedacteurInterfaceState extends State<RedacteurInterface> {
  final DatabaseManager _dbManager = DatabaseManager();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  List<Redacteur> _redacteurs = [];

  @override
  void initState() {
    super.initState();

    _chargerRedacteurs();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _chargerRedacteurs() async {
    final liste = await _dbManager.getAllRedacteurs();
    setState(() {
      _redacteurs = liste;
    });
  }

  Future<void> _ajouterRedacteur() async {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final email = _emailController.text.trim();

    if (nom.isEmpty || prenom.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci de remplir tous les champs.')),
      );
      return;
    }

    final nouveauRedacteur = Redacteur.sansId(
      nom: nom,
      prenom: prenom,
      email: email,
    );

    await _dbManager.insertRedacteur(nouveauRedacteur);

    _nomController.clear();
    _prenomController.clear();
    _emailController.clear();

    await _chargerRedacteurs();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rédacteur ajouté avec succès.')),
      );
    }
  }

  Future<void> _modifierRedacteur(Redacteur redacteur) async {
    final nomCtrl = TextEditingController(text: redacteur.nom);
    final prenomCtrl = TextEditingController(text: redacteur.prenom);
    final emailCtrl = TextEditingController(text: redacteur.email);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier Rédacteur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomCtrl,
              decoration: const InputDecoration(labelText: 'Nouveau Nom'),
            ),
            TextField(
              controller: prenomCtrl,
              decoration: const InputDecoration(labelText: 'Nouveau Prénom'),
            ),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Nouvel Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final nom = nomCtrl.text.trim();
              final prenom = prenomCtrl.text.trim();
              final email = emailCtrl.text.trim();
              if (nom.isEmpty || prenom.isEmpty || email.isEmpty) return;

              final redacteurModifie = Redacteur(
                id: redacteur.id,
                nom: nom,
                prenom: prenom,
                email: email,
              );

              await _dbManager.updateRedacteur(redacteurModifie);
              await _chargerRedacteurs();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _supprimerRedacteur(Redacteur redacteur) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer ${redacteur.prenom} ${redacteur.nom} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await _dbManager.deleteRedacteur(redacteur.id!);
              await _chargerRedacteurs();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des rédacteurs',),
        backgroundColor: Colors.pink,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: _prenomController,
              decoration: const InputDecoration(labelText: 'Prénom'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _ajouterRedacteur,
                icon: const Icon(Icons.add, color: Colors.pink,),
                label: const Text('Ajouter un Rédacteur', selectionColor: Colors.pink,),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _redacteurs.isEmpty
                  ? const Center(child: Text('Aucun rédacteur enregistré.'))
                  : ListView.builder(
                itemCount: _redacteurs.length,
                itemBuilder: (context, index) {
                  final redacteur = _redacteurs[index];
                  return Card(
                    child: ListTile(
                      title: Text('${redacteur.prenom} ${redacteur.nom}'),
                      subtitle: Text(redacteur.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _modifierRedacteur(redacteur),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _supprimerRedacteur(redacteur),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
