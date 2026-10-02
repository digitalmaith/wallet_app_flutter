import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'pin_screen.dart';

class OtpScreen extends StatefulWidget {
  final String telephone;
  final String email;
  const OtpScreen({super.key, required this.telephone, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _emailOtpCtrl = TextEditingController();
  final _smsOtpCtrl = TextEditingController();

  bool _emailVerifie = false;
  bool _smsVerifie = false;
  bool _loadingEmail = false;
  bool _loadingSms = false;

  Future<void> _verifierEmail() async {
    if (_emailOtpCtrl.text.trim().isEmpty) return;
    setState(() => _loadingEmail = true);
    try {
      await AuthService.verifierOtp(
        destinataire: widget.email,
        type: 'EMAIL',
        code: _emailOtpCtrl.text.trim(),
      );
      setState(() => _emailVerifie = true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Email vérifié !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loadingEmail = false);
    }
  }

  Future<void> _verifierSms() async {
    if (_smsOtpCtrl.text.trim().isEmpty) return;
    setState(() => _loadingSms = true);
    try {
      await AuthService.verifierOtp(
        destinataire: widget.telephone,
        type: 'TELEPHONE',
        code: _smsOtpCtrl.text.trim(),
      );
      setState(() => _smsVerifie = true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Téléphone vérifié !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loadingSms = false);
    }
  }

  void _continuer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PinScreen(telephone: widget.telephone),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final toutVerifie = _emailVerifie && _smsVerifie;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Vérifie ton email et ton téléphone',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Saisis les 2 codes reçus',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),

            // ============ EMAIL ============
            _buildBloc(
              icon: Icons.email,
              titre: 'Code Email',
              sousTitre: widget.email,
              controller: _emailOtpCtrl,
              verifie: _emailVerifie,
              loading: _loadingEmail,
              onVerifier: _verifierEmail,
            ),
            const SizedBox(height: 20),

            // ============ SMS ============
            _buildBloc(
              icon: Icons.phone_android,
              titre: 'Code SMS',
              sousTitre: widget.telephone,
              controller: _smsOtpCtrl,
              verifie: _smsVerifie,
              loading: _loadingSms,
              onVerifier: _verifierSms,
            ),

            const SizedBox(height: 30),

            // ============ CONTINUER ============
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: toutVerifie ? _continuer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Text(
                  toutVerifie ? 'Continuer' : 'Vérifie les 2 codes',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloc({
    required IconData icon,
    required String titre,
    required String sousTitre,
    required TextEditingController controller,
    required bool verifie,
    required bool loading,
    required VoidCallback onVerifier,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: verifie ? Colors.green : Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: verifie ? Colors.green.shade50 : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: verifie ? Colors.green : Colors.deepPurple),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(sousTitre, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              if (verifie)
                const Icon(Icons.check_circle, color: Colors.green, size: 28),
            ],
          ),
          const SizedBox(height: 12),
          if (!verifie)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, letterSpacing: 4),
                    decoration: const InputDecoration(
                      hintText: '1234',
                      border: OutlineInputBorder(),
                      counterText: '',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: loading ? null : onVerifier,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Vérifier'),
                  ),
                ),
              ],
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Vérifié ✅', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}