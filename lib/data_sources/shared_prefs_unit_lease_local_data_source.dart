import 'dart:convert';

import 'package:landlord_management_app/data_sources/unit_lease_local_data_source.dart';
import 'package:landlord_management_app/models/unit_lease.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUnitLeaseLocalDataSource implements UnitLeaseLocalDataSource {
  SharedPrefsUnitLeaseLocalDataSource(this._prefs);

  static const _leasesKey = 'unit_leases_v1';
  final SharedPreferences _prefs;

  static Future<SharedPrefsUnitLeaseLocalDataSource> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPrefsUnitLeaseLocalDataSource(prefs);
  }

  @override
  Future<List<UnitLease>?> loadLeases() async {
    final raw = _prefs.getString(_leasesKey);
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! List) return null;

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(UnitLease.fromJson)
        .toList();
  }

  @override
  Future<void> saveLeases(List<UnitLease> leases) async {
    final encoded = jsonEncode(leases.map((lease) => lease.toJson()).toList());
    await _prefs.setString(_leasesKey, encoded);
  }
}
