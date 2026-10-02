import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import 'depot_screen.dart';
import 'retrait_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SoldeModel? _solde;
  List<TransactionModel> _transactions = [];
  bool _loading = true;
  String? _erreur;

  // Couleur principale Wave (violet)
  static const Color waveViolet = Color(0xFF4C1D95);

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() {
      _loading = true;
      _erreur = null;
    });
    try {
      final solde = await WalletService.getSolde();
      final transactions = await WalletService.getTransactions();
      setState(() {
        _solde = solde;
        _transactions = transactions;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _erreur = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deconnecter() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: RefreshIndicator(
        onRefresh: _charger,
        child: CustomScrollView(
          slivers: [
            // ========== HEADER VIOLET ==========
            SliverToBoxAdapter(child: _buildHeader()),

            // ========== BOUTONS ACTIONS ==========
            SliverToBoxAdapter(child: _buildActions()),

            // ========== TITRE TRANSACTIONS ==========
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'Historique',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // ========== LISTE TRANSACTIONS ==========
            if (_loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (_erreur != null)
              SliverToBoxAdapter(child: _buildErreur())
            else if (_transactions.isEmpty)
              SliverToBoxAdapter(child: _buildVide())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildTransactionTile(_transactions[i]),
                  childCount: _transactions.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  // ============================================
  // HEADER VIOLET avec le solde
  // ============================================
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar : avatar + nom + logout
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white24,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bienvenue 👋',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      _solde?.telephone ?? 'Chargement...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _deconnecter,
                icon: const Icon(Icons.logout, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Label solde
          const Text(
            'Solde disponible',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),

          // Montant
          if (_loading)
            const SizedBox(
              height: 40,
              child: Center(
                child: SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
              ),
            )
          else if (_solde != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatMontant(_solde!.solde),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    _solde!.devise,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),

          // Statut compte
          if (_solde != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _solde!.statut == 'ACTIF'
                    ? Colors.green.withOpacity(0.9)
                    : Colors.orange.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _solde!.statut,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================
  // BOUTONS ACTIONS (style Wave)
  // ============================================
  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          _actionButton(
            Icons.add_circle_outline,
            'Déposer',
            Colors.green,
            onTap: () async {
              final refresh = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DepotScreen()),
              );
              if (refresh == true) _charger();
            },
          ),
          const SizedBox(width: 12),
                    _actionButton(
            Icons.remove_circle_outline,
            'Retirer',
            Colors.orange,
            onTap: () async {
              final refresh = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RetraitScreen(soldeActuel: _solde?.solde),
                ),
              );
              if (refresh == true) _charger();
            },
          ),
          const SizedBox(width: 12),
          _actionButton(
            Icons.send_outlined,
            'Envoyer',
            waveViolet,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Envoyer - À venir')),
              );
            },
          ),
          const SizedBox(width: 12),
          _actionButton(
            Icons.receipt_long_outlined,
            'Payer',
            Colors.blue,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payer - À venir')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label - À venir')),
              );
            },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // TILE TRANSACTION
  // ============================================
  Widget _buildTransactionTile(TransactionModel tx) {
    final entree = tx.isEntree;
    final couleur = entree ? Colors.green : Colors.red;
    final icone = entree
        ? Icons.arrow_downward
        : (tx.type == 'PAIEMENT' ? Icons.shopping_bag : Icons.arrow_upward);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: couleur.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, color: couleur, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description ?? tx.type,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(tx.dateCreation),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${entree ? '+' : '-'} ${_formatMontant(tx.montant)}',
            style: TextStyle(
              color: couleur,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // VIDES / ERREURS
  // ============================================
  Widget _buildVide() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Aucune transaction',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
          Text(
            'Tes opérations apparaîtront ici',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErreur() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 40),
          const SizedBox(height: 8),
          Text(
            'Erreur de chargement',
            style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _erreur ?? '',
            style: TextStyle(color: Colors.red.shade400, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _charger,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  // ============================================
  // FORMATTERS
  // ============================================
  String _formatMontant(double montant) {
    // 1250000.0 → 1 250 000
    final parts = montant.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      buffer.write(parts[i]);
      final reste = parts.length - i - 1;
      if (reste > 0 && reste % 3 == 0) buffer.write(' ');
    }
    return buffer.toString();
  }

  String _formatDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} à ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}