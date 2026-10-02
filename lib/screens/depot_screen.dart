import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/wallet_service.dart';

class DepotScreen extends StatefulWidget {
  const DepotScreen({super.key});

  @override
  State<DepotScreen> createState() => _DepotScreenState();
}

class _DepotScreenState extends State<DepotScreen> {
  final _montantCtrl = TextEditingController();
  bool _loading = false;

  // Montants rapides
  final List<int> _montantsRapides = [1000, 2000, 5000, 10000, 25000, 50000];

  Future<void> _deposer() async {
    final montant = double.tryParse(_montantCtrl.text.trim());
    if (montant == null || montant <= 0) {
      _snack('Montant invalide', Colors.red);
      return;
    }

    setState(() => _loading = true);
    try {
      await WalletService.depot(montant: montant);
      if (!mounted) return;
      _snack('Dépôt de $montant XOF réussi ✅', Colors.green);
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.pop(context, true); // true = il faut rafraîchir
    } catch (e) {
      if (!mounted) return;
      _snack('$e', Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, Color couleur) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: couleur),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Déposer'),
        backgroundColor: const Color(0xFF4C1D95),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            // Icône
            Center(
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_circle_outline, color: Colors.green, size: 40),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Combien veux-tu déposer ?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Choisis un montant ou saisis-le manuellement',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 30),

            // Champ montant
            TextField(
              controller: _montantCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: '0',
                suffixText: 'XOF',
                suffixStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Montants rapides
            const Text(
              'Montants rapides',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _montantsRapides.map((m) {
                return GestureDetector(
                  onTap: () {
                    _montantCtrl.text = m.toString();
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: _montantCtrl.text == m.toString()
                          ? const Color(0xFF4C1D95)
                          : const Color(0xFFF0EDF5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$m',
                      style: TextStyle(
                        color: _montantCtrl.text == m.toString()
                            ? Colors.white
                            : const Color(0xFF4C1D95),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // Bouton
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _loading ? null : _deposer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Confirmer le dépôt',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}