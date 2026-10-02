class SoldeModel {
  final String compteId;
  final String telephone;
  final double solde;
  final String devise;
  final String statut;

  SoldeModel({
    required this.compteId,
    required this.telephone,
    required this.solde,
    required this.devise,
    required this.statut,
  });

  factory SoldeModel.fromJson(Map<String, dynamic> json) {
    return SoldeModel(
      compteId: json['compteId'] ?? '',
      telephone: json['telephone'] ?? '',
      solde: (json['solde'] ?? 0).toDouble(),
      devise: json['devise'] ?? 'XOF',
      statut: json['statut'] ?? 'ACTIF',
    );
  }
}

class TransactionModel {
  final String id;
  final String type;        // DEPOT, RETRAIT, PAIEMENT
  final double montant;
  final String statut;      // EN_ATTENTE, SUCCES, ECHEC
  final String? description;
  final String dateCreation;

  TransactionModel({
    required this.id,
    required this.type,
    required this.montant,
    required this.statut,
    this.description,
    required this.dateCreation,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      montant: (json['montant'] ?? 0).toDouble(),
      statut: json['statut'] ?? '',
      description: json['description'],
      dateCreation: json['dateCreation'] ?? '',
    );
  }

  // Icônes et couleurs selon le type
  bool get isEntree => type == 'DEPOT';
  bool get isSortie => type == 'RETRAIT' || type == 'PAIEMENT';
}