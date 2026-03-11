import 'package:landlord_management_app/models/unit_lease.dart';
import 'package:landlord_management_app/repositories/unit_lease_repository.dart';
import 'package:landlord_management_app/utils/unit_lease_formatters.dart';

class HomeDashboardData {
  HomeDashboardData({
    required this.now,
    required this.todayContactLeases,
    required this.negotiatingLeases,
    required this.thisMonthExpiringLeases,
    required this.top3ExpiringLeases,
  });

  factory HomeDashboardData.fromRepository(
    UnitLeaseRepository repository, {
    DateTime? now,
  }) {
    final currentDate = now ?? DateTime.now();
    final leases = repository.getLeasesSortedByLeaseEnd();
    final todayContactLeases = leases.where((lease) {
      final nextContactDate = lease.nextContactDate;
      return nextContactDate != null &&
          isSameCalendarDate(nextContactDate, currentDate);
    }).toList();
    final negotiatingLeases = leases
        .where((lease) => lease.status == LeaseStatus.negotiating)
        .toList();
    final thisMonthExpiringLeases = leases.where((lease) {
      return lease.leaseEnd.year == currentDate.year &&
          lease.leaseEnd.month == currentDate.month;
    }).toList();

    return HomeDashboardData(
      now: currentDate,
      todayContactLeases: todayContactLeases,
      negotiatingLeases: negotiatingLeases,
      thisMonthExpiringLeases: thisMonthExpiringLeases,
      top3ExpiringLeases: repository.getTopExpiringLeases(3),
    );
  }

  final DateTime now;
  final List<UnitLease> todayContactLeases;
  final List<UnitLease> negotiatingLeases;
  final List<UnitLease> thisMonthExpiringLeases;
  final List<UnitLease> top3ExpiringLeases;

  int get contactTodayCount => todayContactLeases.length;
  int get negotiatingCount => negotiatingLeases.length;
  int get expiringThisMonthCount => thisMonthExpiringLeases.length;
  List<UnitLease> get top3ContactToday => todayContactLeases.take(3).toList();
}
