import 'package:flutter/material.dart';
import 'package:landlord_management_app/models/unit_lease.dart';
import 'package:landlord_management_app/repositories/unit_lease_repository.dart';
import 'package:landlord_management_app/screens/add_unit_screen.dart';
import 'package:landlord_management_app/screens/unit_detail_screen.dart';
import 'package:landlord_management_app/screens/units_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final UnitLeaseRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _openAddUnitScreen() async {
    final created = await Navigator.of(context).push<UnitLease>(
      MaterialPageRoute<UnitLease>(
        builder: (_) => const AddUnitScreen(),
      ),
    );
    if (created == null) return;
    if (!mounted) return;
    setState(() {
      widget.repository.addLease(created);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('새 호실 계약을 추가했습니다.')),
    );
  }

  Future<void> _openFilteredList({
    required String title,
    required UnitLeaseFilter filter,
    required String emptyMessage,
  }) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => UnitsListScreen(
          repository: widget.repository,
          title: title,
          filter: filter,
          emptyMessage: emptyMessage,
        ),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final leases = widget.repository.getLeasesSortedByLeaseEnd();
    final top3Expiring = widget.repository.getTopExpiringLeases(3);
    final now = DateTime.now();
    final expiringThisMonth = widget.repository.countExpiringInMonth(now);
    final todayContactLeases = leases.where((lease) {
      final nextContactDate = lease.nextContactDate;
      return nextContactDate != null && _isSameDate(nextContactDate, now);
    }).toList();
    final contactTodayCount = todayContactLeases.length;
    final top3ContactToday = todayContactLeases.take(3).toList();
    final negotiatingCount =
        leases.where((lease) => lease.status == LeaseStatus.negotiating).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '임대 관리 홈',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        children: [
          Text(
            '오늘 해야 할 일',
            style: textTheme.headlineSmall?.copyWith(
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '중요한 연락과 계약 만료 일정을 먼저 확인하세요.',
            style: TextStyle(fontSize: 21),
          ),
          const SizedBox(height: 16),
          _SummaryCard(
            title: '오늘 연락할 항목',
            countText: '$contactTodayCount건',
            highlightColor: const Color(0xFF0D6E6E),
            helperText: contactTodayCount == 0
                ? '오늘 바로 연락할 항목이 없습니다.'
                : '눌러서 오늘 연락할 호실을 바로 보세요.',
            onTap: () => _openFilteredList(
              title: '오늘 연락할 항목',
              filter: (repository) =>
                  repository.getLeasesSortedByLeaseEnd().where((lease) {
                final nextContactDate = lease.nextContactDate;
                return nextContactDate != null &&
                    _isSameDate(nextContactDate, now);
              }).toList(),
              emptyMessage: '오늘 연락할 호실이 없습니다.',
            ),
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            title: '협의중',
            countText: '$negotiatingCount건',
            highlightColor: const Color(0xFF8A5A00),
            helperText: negotiatingCount == 0
                ? '지금 협의중인 호실이 없습니다.'
                : '눌러서 협의중인 호실을 확인하세요.',
            onTap: () => _openFilteredList(
              title: '협의중',
              filter: (repository) => repository
                  .getLeasesSortedByLeaseEnd()
                  .where((lease) => lease.status == LeaseStatus.negotiating)
                  .toList(),
              emptyMessage: '협의중인 호실이 없습니다.',
            ),
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            title: '이번 달 만료',
            countText: '$expiringThisMonth건',
            highlightColor: Theme.of(context).colorScheme.primary,
            helperText: expiringThisMonth == 0
                ? '이번 달 만료 예정이 없습니다.'
                : '눌러서 이번 달 만료 호실을 확인하세요.',
            onTap: () => _openFilteredList(
              title: '이번 달 만료',
              filter: (repository) => repository
                  .getLeasesSortedByLeaseEnd()
                  .where((lease) =>
                      lease.leaseEnd.year == now.year &&
                      lease.leaseEnd.month == now.month)
                  .toList(),
              emptyMessage: '이번 달 만료 예정 호실이 없습니다.',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _openAddUnitScreen,
              child: const Text(
                '호실 추가',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '오늘 연락할 목록',
            style: textTheme.headlineSmall?.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '오늘 바로 처리하면 좋은 연락 일정입니다.',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 12),
          if (top3ContactToday.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  '오늘 연락할 항목이 없습니다.',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ...top3ContactToday.map(
            (unit) => _ContactTodayTile(
              unit: unit,
              onUpdated: (updated) => setState(
                () => widget.repository.updateLease(updated),
              ),
              onDeleted: (id) => setState(
                () => widget.repository.deleteLeaseById(id),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '만료 임박 TOP 3',
            style: textTheme.headlineSmall?.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '계약 만료가 가까운 순서대로 살펴보세요.',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 12),
          ...top3Expiring.map(
            (unit) => _UnitTile(
              unit: unit,
              onUpdated: (updated) => setState(
                () => widget.repository.updateLease(updated),
              ),
              onDeleted: (id) => setState(
                () => widget.repository.deleteLeaseById(id),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      UnitsListScreen(repository: widget.repository),
                ),
              );
              if (!mounted) return;
              setState(() {});
            },
            child: const Text(
              '호실 전체 보기',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.countText,
    required this.highlightColor,
    required this.helperText,
    required this.onTap,
  });

  final String title;
  final String countText;
  final Color highlightColor;
  final String helperText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 34),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                countText,
                style: textTheme.displaySmall?.copyWith(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: highlightColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                helperText,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitTile extends StatelessWidget {
  const _UnitTile({
    required this.unit,
    required this.onUpdated,
    required this.onDeleted,
  });

  final UnitLease unit;
  final ValueChanged<UnitLease> onUpdated;
  final ValueChanged<String> onDeleted;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () async {
          final result = await Navigator.of(context).push<UnitDetailResult>(
            MaterialPageRoute<UnitDetailResult>(
              builder: (_) => UnitDetailScreen(unit: unit),
            ),
          );
          if (result == null) return;
          if (result.deleted) {
            onDeleted(unit.id);
            return;
          }
          if (result.unit != null) onUpdated(result.unit!);
        },
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(
          unit.unitNo,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '${unit.buildingName} · ${unit.tenantName} · ${_dateToText(unit.leaseEnd)} 만료',
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

class _ContactTodayTile extends StatelessWidget {
  const _ContactTodayTile({
    required this.unit,
    required this.onUpdated,
    required this.onDeleted,
  });

  final UnitLease unit;
  final ValueChanged<UnitLease> onUpdated;
  final ValueChanged<String> onDeleted;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () async {
          final result = await Navigator.of(context).push<UnitDetailResult>(
            MaterialPageRoute<UnitDetailResult>(
              builder: (_) => UnitDetailScreen(unit: unit),
            ),
          );
          if (result == null) return;
          if (result.deleted) {
            onDeleted(unit.id);
            return;
          }
          if (result.unit != null) onUpdated(result.unit!);
        },
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          unit.unitNo,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '${unit.tenantName} · ${_statusText(unit.status)}',
            style: const TextStyle(fontSize: 21),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 32),
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
}
