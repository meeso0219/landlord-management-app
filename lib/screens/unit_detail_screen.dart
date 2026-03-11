import 'package:flutter/material.dart';
import 'package:landlord_management_app/models/unit_lease.dart';
import 'package:landlord_management_app/screens/add_unit_screen.dart';
import 'package:landlord_management_app/utils/unit_lease_formatters.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UnitDetailResult {
  const UnitDetailResult.updated(this.unit) : deleted = false;
  const UnitDetailResult.deleted()
      : unit = null,
        deleted = true;

  final UnitLease? unit;
  final bool deleted;
}

class UnitDetailScreen extends StatefulWidget {
  const UnitDetailScreen({super.key, required this.unit});

  final UnitLease unit;

  @override
  State<UnitDetailScreen> createState() => _UnitDetailScreenState();
}

class _UnitDetailScreenState extends State<UnitDetailScreen> {
  late UnitLease _unit;

  @override
  void initState() {
    super.initState();
    _unit = widget.unit;
  }

  void _updateUnit(UnitLease updated) {
    setState(() {
      _unit = updated;
    });
  }

  void _renewTwoYears() {
    final end = _unit.leaseEnd;
    _updateUnit(
      _unit.copyWith(
        leaseEnd: DateTime(end.year + 2, end.month, end.day),
        status: LeaseStatus.active,
        nextContactDate: null,
      ),
    );
    _showActionSnackBar('계약을 2년 갱신했습니다.');
  }

  Future<void> _pickNextContactDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _unit.nextContactDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      helpText: '다음 연락일 선택',
      confirmText: '저장',
      cancelText: '취소',
    );
    if (pickedDate == null) return;
    _updateUnit(
      _unit.copyWith(
        nextContactDate: pickedDate,
      ),
    );
    _showActionSnackBar('다음 연락일을 저장했습니다.');
  }

  void _clearNextContactDate() {
    if (_unit.nextContactDate == null) {
      _showActionSnackBar('삭제할 다음 연락일이 없습니다.');
      return;
    }
    _updateUnit(
      _unit.copyWith(
        nextContactDate: null,
      ),
    );
    _showActionSnackBar('다음 연락일을 삭제했습니다.');
  }

  void _setNegotiating() {
    _updateUnit(
      _unit.copyWith(
        status: LeaseStatus.negotiating,
      ),
    );
    _showActionSnackBar('상태를 협의중으로 변경했습니다.');
  }

  void _setEnded() {
    _updateUnit(
      _unit.copyWith(
        status: LeaseStatus.ended,
        nextContactDate: null,
      ),
    );
    _showActionSnackBar('계약을 종료/퇴거 상태로 변경했습니다.');
  }

  Future<void> _callTenant() async {
    final phoneNumber = _unit.tenantPhone.trim();
    final phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    final launched = await launchUrl(phoneUri);
    if (!launched && mounted) {
      _showActionSnackBar('전화 앱을 열 수 없습니다.');
    }
  }

  Future<void> _shareMessage() async {
    await Share.share(_buildShareMessage());
  }

  String _buildShareMessage() {
    return '${_unit.tenantName}님, 안녕하세요.\n'
        '${_unit.buildingName} ${_unit.unitNo} 계약 안내드립니다.\n'
        '계약 종료일은 ${formatLeaseDate(_unit.leaseEnd)}입니다.';
  }

  Future<void> _openEditScreen() async {
    final updated = await Navigator.of(context).push<UnitLease>(
      MaterialPageRoute<UnitLease>(
        builder: (_) => AddUnitScreen(initialUnit: _unit),
      ),
    );
    if (updated == null) return;
    _updateUnit(updated);
    if (!mounted) return;
    Navigator.of(context).pop(UnitDetailResult.updated(_unit));
  }

  void _showActionSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      );
  }

  void _closeWithResult() {
    Navigator.of(context).pop(UnitDetailResult.updated(_unit));
  }

  Future<void> _deleteUnit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '호실 삭제',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          content: const Text(
            '이 호실 정보를 정말 삭제하시겠습니까?',
            style: TextStyle(fontSize: 22),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                '취소',
                style: TextStyle(fontSize: 20),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                '삭제',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    Navigator.of(context).pop(const UnitDetailResult.deleted());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _closeWithResult();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${_unit.unitNo} 상세',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _closeWithResult,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 20),
              _sectionHeader(
                title: '빠른 작업',
                helperText: '아래 버튼으로 바로 연락하거나 일정을 정할 수 있습니다.',
              ),
              const SizedBox(height: 12),
              _actionButton(
                label: '전화하기',
                onPressed: _callTenant,
              ),
              const SizedBox(height: 10),
              _actionButton(
                label: '문자/공유',
                onPressed: _shareMessage,
              ),
              const SizedBox(height: 10),
              _actionButton(
                label:
                    _unit.nextContactDate == null ? '다음 연락일 정하기' : '다음 연락일 수정',
                onPressed: _pickNextContactDate,
              ),
              const SizedBox(height: 8),
              const Text(
                '정한 연락일은 홈 화면의 연락 목록에 표시됩니다.',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              _actionButton(
                label: '다음 연락일 삭제',
                onPressed: _unit.nextContactDate == null
                    ? null
                    : _clearNextContactDate,
              ),
              const SizedBox(height: 10),
              _actionButton(
                label: '협의중으로 변경',
                onPressed: _setNegotiating,
              ),
              const SizedBox(height: 24),
              _sectionHeader(
                title: '계약 처리',
                helperText: '계약 내용을 반영합니다.',
              ),
              const SizedBox(height: 12),
              _actionButton(
                label: '갱신 (+2년)',
                onPressed: _renewTwoYears,
              ),
              const SizedBox(height: 10),
              _actionButton(
                label: '종료/퇴거',
                onPressed: _setEnded,
              ),
              const SizedBox(height: 24),
              _sectionHeader(title: '정보 관리'),
              const SizedBox(height: 12),
              _actionButton(
                label: '정보 수정',
                onPressed: _openEditScreen,
              ),
              const SizedBox(height: 10),
              _actionButton(
                label: '삭제',
                onPressed: _deleteUnit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '상단 요약 정보',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            _summaryRow('건물', _unit.buildingName),
            const SizedBox(height: 10),
            _summaryRow('호실', _unit.unitNo),
            const SizedBox(height: 10),
            _summaryRow('세입자', _unit.tenantName),
            const SizedBox(height: 10),
            _summaryRow('연락처', _unit.tenantPhone),
            const SizedBox(height: 14),
            _highlightRow('계약 종료일', formatLeaseDate(_unit.leaseEnd)),
            const SizedBox(height: 10),
            _highlightRow('만료까지',
                formatLeaseCountdown(_unit.daysRemainingUntilLeaseEnd())),
            const SizedBox(height: 10),
            _highlightRow('상태', leaseStatusText(_unit.status)),
            const SizedBox(height: 10),
            _highlightRow(
              '다음 연락일',
              _unit.nextContactDate == null
                  ? '미정'
                  : formatLeaseDate(_unit.nextContactDate!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText,
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 23),
          ),
        ),
      ],
    );
  }

  Widget _highlightRow(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
