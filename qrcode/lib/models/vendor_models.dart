// lib/models/vendor_models.dart

// Solde du Vendeur
class VendeurSoldeResponse {
  final double solde;
  final String devise;
  final String lastUpdateTime;
  final String message;

  VendeurSoldeResponse({
    required this.solde,
    this.devise = 'XAF',
    required this.lastUpdateTime,
    required this.message,
  });

  factory VendeurSoldeResponse.fromJson(Map<String, dynamic> json) {
    return VendeurSoldeResponse(
      solde: (json['solde'] ?? 0).toDouble(),
      devise: json['devise'] ?? 'XAF',
      lastUpdateTime: json['derniereMiseAJour'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

// Transaction
class Transaction {
  final int id;
  final double montant;
  final String statut; // SUCCESS, PENDING, FAILED
  final String dateCreation;
  final String clientPhone;
  final String description;

  Transaction({
    required this.id,
    required this.montant,
    required this.statut,
    required this.dateCreation,
    required this.clientPhone,
    required this.description,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      montant: (json['montant'] ?? 0).toDouble(),
      statut: json['statut'] ?? 'PENDING',
      dateCreation: json['dateCreation'] ?? '',
      clientPhone: json['clientPhone'] ?? 'N/A',
      description: json['description'] ?? '',
    );
  }
}

// Liste des Transactions avec pagination
class TransactionListResponse {
  final List<Transaction> transactions;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final bool hasNextPage;
  final bool hasPreviousPage;

  TransactionListResponse({
    required this.transactions,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory TransactionListResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> content = json['content'] ?? [];
    return TransactionListResponse(
      transactions: content.map((t) => Transaction.fromJson(t)).toList(),
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 0,
      pageSize: json['pageSize'] ?? 10,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
    );
  }
}

// Retrait
class Retrait {
  final int id;
  final double montant;
  final String statut; // PENDING, SUCCESS, FAILED
  final String dateCreation;
  final String operateur; // MTN_Cameroon, Orange_Cameroon
  final String? referenceId;
  final String? message;

  Retrait({
    required this.id,
    required this.montant,
    required this.statut,
    required this.dateCreation,
    required this.operateur,
    this.referenceId,
    this.message,
  });

  factory Retrait.fromJson(Map<String, dynamic> json) {
    return Retrait(
      id: json['id'] ?? 0,
      montant: (json['montant'] ?? 0).toDouble(),
      statut: json['statut'] ?? 'PENDING',
      dateCreation: json['dateCreation'] ?? '',
      operateur: json['operateur'] ?? 'MTN_Cameroon',
      referenceId: json['referenceId'],
      message: json['message'],
    );
  }
}

// Liste des Retraits avec pagination
class RetraitListResponse {
  final List<Retrait> retraits;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final bool hasNextPage;
  final bool hasPreviousPage;

  RetraitListResponse({
    required this.retraits,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory RetraitListResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> content = json['content'] ?? [];
    return RetraitListResponse(
      retraits: content.map((r) => Retrait.fromJson(r)).toList(),
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 0,
      pageSize: json['pageSize'] ?? 10,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
    );
  }
}

// Request pour retrait
class RetraitRequest {
  final double montant;
  final String operateur; // MTN_Cameroon, Orange_Cameroon

  RetraitRequest({required this.montant, required this.operateur});

  Map<String, dynamic> toJson() => {'montant': montant, 'operateur': operateur};
}
