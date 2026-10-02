import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/wallet_service.dart';

class RetraitScreen extends StatefulWidget {
  final double? soldeActuel;
  const RetraitScreen({super.key, this.soldeActuel});

  @override
  State<RetraitScreen> createState() => _RetraitScreenState();
}

class _RetraitScreenState extends State<RetraitScreen> {
  final _montantCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePin = true;

  final List<int> _montantsRapides = [1000, 2000, 5000, 10000, 25000, 50000];

  Future<void> _retirer() async {
    final montant = double.tryParse(_montantCtrl.text.trim());
    if (montant == null || montant <= 0) {
      _snack('Montant invalide', Colors.red);
      return;
    }
    if (widget.soldeActuel != null && montant > widget.soldeActuel!) {
      _snack('Solde insuffisant (${widget.soldeActuel} XOF dispo)', Colors.orange);
      return;
    }
    if (_pinCtrl.text.trim().length < 4) {
      _snack('PIN invalide (min 4 chiffres)', Colors.red);
      return;
    }

    setState(() => _loading = true);
    try {
      await WalletService.retrait(
        montant: montant,
        pin: _pinCtrl.text.trim(),
      );
      if (!mounted) return;
      _snack('Retrait de $montant XOF réussi ✅', Colors.green);
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
        title: const Text('Retirer'),
        backgroundColor: Colors.orange,
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
                  color: Colors.orange.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.remove_circle_outline,
                    color: Colors.orange, size: 40),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Combien veux-tu retirer ?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.soldeActuel != null
                  ? 'Solde dispo : ${_formatMontant(widget.soldeActuel!)} XOF'
                  : 'Saisis le montant et ton PIN',
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
                final selected = _montantCtrl.text == m.toString();
                return GestureDetector(
                  onTap: () {
                    _montantCtrl.text = m.toString();
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? Colors.orange : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$m',
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // ============ PIN ============
            const Text(
              'Confirme avec ton PIN',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pinCtrl,
              keyboardType: TextInputType.number,
              obscureText: _obscurePin,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: '••••',
                border: const OutlineInputBorder(),
                counterText: '',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePin ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePin = !_obscurePin),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Bouton
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _loading ? null : _retirer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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
                        'Confirmer le retrait',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMontant(double montant) {
    final parts = montant.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      buffer.write(parts[i]);
      final reste = parts.length - i - 1;
      if (reste > 0 && reste % 3 == 0) buffer.write(' ');
    }
    return buffer.toString();
  }
}