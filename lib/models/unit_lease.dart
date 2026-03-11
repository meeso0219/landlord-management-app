enum LeaseStatus { active, negotiating, ended }

const Object _nextContactDateNotProvided = Object();

class UnitLease {
  const UnitLease({
    required this.id,
    required this.buildingName,
    required this.unitNo,
    required this.tenantName,
    required this.tenantPhone,
    required this.leaseStart,
    required this.leaseEnd,
    required this.status,
    this.nextContactDate,
  });

  final String id;
  final String buildingName;
  final String unitNo;
  final String tenantName;
  final String tenantPhone;
  final DateTime leaseStart;
  final DateTime leaseEnd;
  final LeaseStatus status;
  final DateTime? nextContactDate;

  int daysRemainingUntilLeaseEnd({DateTime? fromDate}) {
    final base = fromDate ?? DateTime.now();
    final startOfBase = DateTime(base.year, base.month, base.day);
    final endOfLease = DateTime(leaseEnd.year, leaseEnd.month, leaseEnd.day);
    return endOfLease.difference(startOfBase).inDays;
  }

  factory UnitLease.fromJson(Map<String, dynamic> json) {
    return UnitLease(
      id: json['id'] as String,
      buildingName: json['buildingName'] as String,
      unitNo: json['unitNo'] as String,
      tenantName: json['tenantName'] as String,
      tenantPhone: json['tenantPhone'] as String,
      leaseStart: DateTime.parse(json['leaseStart'] as String),
      leaseEnd: DateTime.parse(json['leaseEnd'] as String),
      status: LeaseStatus.values.byName(json['status'] as String),
      nextContactDate: json['nextContactDate'] == null
          ? null
          : DateTime.parse(json['nextContactDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buildingName': buildingName,
      'unitNo': unitNo,
      'tenantName': tenantName,
      'tenantPhone': tenantPhone,
      'leaseStart': leaseStart.toIso8601String(),
      'leaseEnd': leaseEnd.toIso8601String(),
      'status': status.name,
      'nextContactDate': nextContactDate?.toIso8601String(),
    };
  }

  UnitLease copyWith({
    String? id,
    String? buildingName,
    String? unitNo,
    String? tenantName,
    String? tenantPhone,
    DateTime? leaseStart,
    DateTime? leaseEnd,
    LeaseStatus? status,
    Object? nextContactDate = _nextContactDateNotProvided,
  }) {
    return UnitLease(
      id: id ?? this.id,
      buildingName: buildingName ?? this.buildingName,
      unitNo: unitNo ?? this.unitNo,
      tenantName: tenantName ?? this.tenantName,
      tenantPhone: tenantPhone ?? this.tenantPhone,
      leaseStart: leaseStart ?? this.leaseStart,
      leaseEnd: leaseEnd ?? this.leaseEnd,
      status: status ?? this.status,
      nextContactDate: identical(nextContactDate, _nextContactDateNotProvided)
          ? this.nextContactDate
          : nextContactDate as DateTime?,
    );
  }
}
