enum GuideGender { male, female }

enum GuideStatus { unverified, pending, verified, rejected }

class GuideEntity {
  final String id;
  final String fullName;
  final String phone;
  final GuideGender gender;
  final String? avatarUrl;
  final GuideStatus status;
  final DateTime createdAt;

  const GuideEntity({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.gender,
    this.avatarUrl,
    required this.status,
    required this.createdAt,
  });

  bool get needsOnboarding =>
      status == GuideStatus.unverified || status == GuideStatus.rejected;

  bool get isPending => status == GuideStatus.pending;
  bool get isVerified => status == GuideStatus.verified;
}
