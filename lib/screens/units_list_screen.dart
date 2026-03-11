import 'package:flutter/material.dart';
import 'package:landlord_management_app/models/unit_lease.dart';
import 'package:landlord_management_app/repositories/unit_lease_repository.dart';
import 'package:landlord_management_app/screens/unit_detail_screen.dart';

class UnitsListScreen extends StatefulWidget {
  const UnitsListScreen({super.key, required this.repository});

  final UnitLeaseRepository repository;

  @override
  State<UnitsListScreen> createState() => _UnitsListScreenState();
}

class _UnitsListScreenState extends State<UnitsListScreen> {
  @override
  Widget build(BuildContext context) {
    final units = widget.repository.getLeasesSortedByLeaseEnd();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '전체 호실',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        itemCount: units.length,
        itemBuilder: (context, index) {
          final unit = units[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              onTap: () async {
                final result =
                    await Navigator.of(context).push<UnitDetailResult>(
                  MaterialPageRoute<UnitDetailResult>(
                    builder: (_) => UnitDetailScreen(unit: unit),
                  ),
                );
                if (result == null) return;
                setState(() {
                  if (result.deleted) {
                    widget.repository.deleteLeaseById(unit.id);
                    return;
                  }
                  if (result.unit == null) return;
                  widget.repository.updateLease(result.unit!);
                });
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              title: Text(
                unit.unitNo,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${unit.tenantName} · ${_statusText(unit.status)} · ${_dateToText(unit.leaseEnd)} 만료',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              trailing: Text(
                _dDayText(unit.daysRemainingUntilLeaseEnd()),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _statusText(LeaseStatus status) {
    switch (status) {
      case LeaseStatus.active:
        return '진행중';
      case LeaseStatus.negotiating:
        return '협의중';
      case LeaseStatus.ended:
        return '종료/퇴거';
    }
  }

  String _dateToText(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _dDayText(int days) {
    if (days > 0) return '$days일 남음';
    if (days == 0) return '오늘 만료';
    return '${days.abs()}일 지남';
  }
}
