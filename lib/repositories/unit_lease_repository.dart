import 'package:landlord_management_app/models/unit_lease.dart';

abstract class UnitLeaseRepository {
  List<UnitLease> getLeases();
  List<UnitLease> getLeasesSortedByLeaseEnd();
  List<UnitLease> getTopExpiringLeases(int count);
  int countExpiringInMonth(DateTime month);
  void addLease(UnitLease lease);
  void updateLease(UnitLease lease);
  void deleteLeaseById(String id);
}
