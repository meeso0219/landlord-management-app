import 'package:landlord_management_app/models/unit_lease.dart';

abstract class UnitLeaseLocalDataSource {
  Future<List<UnitLease>?> loadLeases();
  Future<void> saveLeases(List<UnitLease> leases);
}
