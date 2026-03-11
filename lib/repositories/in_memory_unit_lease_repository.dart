import 'dart:async';

import 'package:landlord_management_app/data_sources/unit_lease_local_data_source.dart';
import 'package:landlord_management_app/models/unit_lease.dart';
import 'package:landlord_management_app/repositories/unit_lease_repository.dart';
import 'package:landlord_management_app/services/notification_service.dart';

class InMemoryUnitLeaseRepository implements UnitLeaseRepository {
  InMemoryUnitLeaseRepository({
    List<UnitLease>? initialLeases,
    UnitLeaseLocalDataSource? localDataSource,
  })  : _leases = [...(initialLeases ?? [])],
        _localDataSource = localDataSource;

  static List<UnitLease> buildSampleLeases() {
    final now = DateTime.now();
    return [
      UnitLease(
        id: 'u1',
        buildingName: '해든빌',
        unitNo: '101호',
        tenantName: '김영수 확인용',
        tenantPhone: '010-1234-5678',
        leaseStart: DateTime(now.year - 1, 3, 1),
        leaseEnd: now.add(const Duration(days: 11)),
        status: LeaseStatus.active,
        nextContactDate: now,
      ),
      UnitLease(
        id: 'u2',
        buildingName: '해든빌',
        unitNo: '202호',
        tenantName: '박민지',
        tenantPhone: '010-9876-5432',
        leaseStart: DateTime(now.year - 1, 5, 1),
        leaseEnd: now.add(const Duration(days: 2)),
        status: LeaseStatus.active,
        nextContactDate: now.add(const Duration(days: 2)),
      ),
      UnitLease(
        id: 'u3',
        buildingName: '해든빌',
        unitNo: '303호',
        tenantName: '이준호',
        tenantPhone: '010-2222-3333',
        leaseStart: DateTime(now.year - 1, 7, 1),
        leaseEnd: now.add(const Duration(days: 8)),
        status: LeaseStatus.negotiating,
        nextContactDate: now.add(const Duration(days: 4)),
      ),
      UnitLease(
        id: 'u4',
        buildingName: '해든빌',
        unitNo: '405호',
        tenantName: '최수현',
        tenantPhone: '010-4444-5555',
        leaseStart: DateTime(now.year - 1, 9, 1),
        leaseEnd: now.add(const Duration(days: 20)),
        status: LeaseStatus.active,
        nextContactDate: null,
      ),
      UnitLease(
        id: 'u5',
        buildingName: '해든빌',
        unitNo: '502호',
        tenantName: '정다은',
        tenantPhone: '010-6666-7777',
        leaseStart: DateTime(now.year - 1, 10, 1),
        leaseEnd: now.add(const Duration(days: 5)),
        status: LeaseStatus.ended,
        nextContactDate: now.add(const Duration(days: 2)),
      ),
    ];
  }

  static Future<InMemoryUnitLeaseRepository> create({
    required UnitLeaseLocalDataSource localDataSource,
    List<UnitLease>? fallbackSampleLeases,
  }) async {
    final saved = await localDataSource.loadLeases();
    final initial = (saved != null && saved.isNotEmpty)
        ? saved
        : (fallbackSampleLeases ?? buildSampleLeases());

    final repository = InMemoryUnitLeaseRepository(
      initialLeases: initial,
      localDataSource: localDataSource,
    );
    await NotificationService.instance.syncFollowUpNotifications(initial);
    await NotificationService.instance
        .syncLeaseExpirationNotifications(initial);
    return repository;
  }

  factory InMemoryUnitLeaseRepository.withSampleData() {
    return InMemoryUnitLeaseRepository(
      initialLeases: buildSampleLeases(),
    );
  }

  final List<UnitLease> _leases;
  final UnitLeaseLocalDataSource? _localDataSource;

  void _persist() {
    final localDataSource = _localDataSource;
    if (localDataSource == null) return;
    unawaited(localDataSource.saveLeases(_leases));
  }

  void _syncFollowUpNotification(UnitLease lease) {
    unawaited(NotificationService.instance.syncFollowUpNotification(lease));
  }

  void _syncLeaseExpirationNotification(UnitLease lease) {
    unawaited(
      NotificationService.instance.syncLeaseExpirationNotification(lease),
    );
  }

  @override
  List<UnitLease> getLeases() => [..._leases];

  @override
  List<UnitLease> getLeasesSortedByLeaseEnd() {
    final sorted = [..._leases];
    sorted.sort((a, b) => a.leaseEnd.compareTo(b.leaseEnd));
    return sorted;
  }

  @override
  List<UnitLease> getTopExpiringLeases(int count) {
    return getLeasesSortedByLeaseEnd().take(count).toList();
  }

  @override
  int countExpiringInMonth(DateTime month) {
    return _leases.where((lease) {
      return lease.leaseEnd.year == month.year &&
          lease.leaseEnd.month == month.month;
    }).length;
  }

  @override
  void addLease(UnitLease lease) {
    _leases.add(lease);
    _persist();
    _syncFollowUpNotification(lease);
    _syncLeaseExpirationNotification(lease);
  }

  @override
  void updateLease(UnitLease lease) {
    final index = _leases.indexWhere((item) => item.id == lease.id);
    if (index == -1) return;
    _leases[index] = lease;
    _persist();
    _syncFollowUpNotification(lease);
    _syncLeaseExpirationNotification(lease);
  }

  @override
  void deleteLeaseById(String id) {
    final removedLeases = _leases.where((lease) => lease.id == id).toList();
    _leases.removeWhere((lease) => lease.id == id);
    _persist();
    for (final lease in removedLeases) {
      unawaited(
        NotificationService.instance.cancelFollowUpNotificationByLeaseId(
          lease.id,
        ),
      );
      unawaited(
        NotificationService.instance
            .cancelLeaseExpirationNotificationsByLeaseId(
          lease.id,
        ),
      );
    }
  }
}
