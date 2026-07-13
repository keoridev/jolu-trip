class VerificationStatusModel {
  final String status;

  const VerificationStatusModel({required this.status});

  factory VerificationStatusModel.fromJson(Map<String, dynamic> json) {
    final status = json['status'] is String
        ? json['status'] as String
        : 'unknown';
    return VerificationStatusModel(status: status);
  }

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
  bool get isUnverified => status == 'unverified';
}
