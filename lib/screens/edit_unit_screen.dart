import 'package:flutter/material.dart';
import 'package:landlord_management_app/models/unit_lease.dart';

class EditUnitScreen extends StatefulWidget {
  const EditUnitScreen({super.key, required this.unit});

  final UnitLease unit;

  @override
  State<EditUnitScreen> createState() => _EditUnitScreenState();
}

class _EditUnitScreenState extends State<EditUnitScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _buildingNameController;
  late final TextEditingController _unitNumberController;
  late final TextEditingController _tenantNameController;
  late final TextEditingController _tenantPhoneController;

  late DateTime _leaseStartDate;
  late DateTime _leaseEndDate;

  @override
  void initState() {
    super.initState();
    _buildingNameController = TextEditingController(
      text: widget.unit.buildingName,
    );
    _unitNumberController = TextEditingController(text: widget.unit.unitNo);
    _tenantNameController = TextEditingController(text: widget.unit.tenantName);
    _tenantPhoneController = TextEditingController(
      text: widget.unit.tenantPhone,
    );
    _leaseStartDate = widget.unit.leaseStart;
    _leaseEndDate = widget.unit.leaseEnd;
  }

  @override
  void dispose() {
    _buildingNameController.dispose();
    _unitNumberController.dispose();
    _tenantNameController.dispose();
    _tenantPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime current,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 20),
      helpText: '날짜 선택',
      confirmText: '확인',
      cancelText: '취소',
    );
    if (picked != null) onPicked(picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_leaseEndDate.isBefore(_leaseStartDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('계약 종료일은 시작일 이후여야 합니다.')),
      );
      return;
    }

    final updated = widget.unit.copyWith(
      buildingName: _buildingNameController.text.trim(),
      unitNo: _unitNumberController.text.trim(),
      tenantName: _tenantNameController.text.trim(),
      tenantPhone: _tenantPhoneController.text.trim(),
      leaseStart: _leaseStartDate,
      leaseEnd: _leaseEndDate,
    );
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '호실 정보 수정',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _textField(controller: _buildingNameController, label: '건물명'),
              const SizedBox(height: 14),
              _textField(controller: _unitNumberController, label: '호실 번호'),
              const SizedBox(height: 14),
              _textField(controller: _tenantNameController, label: '세입자 이름'),
              const SizedBox(height: 14),
              _textField(
                controller: _tenantPhoneController,
                label: '세입자 전화번호',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              _dateButton(
                label: '계약 시작일',
                value: _leaseStartDate,
                onTap: () => _pickDate(
                  current: _leaseStartDate,
                  onPicked: (value) => setState(() => _leaseStartDate = value),
                ),
              ),
              const SizedBox(height: 10),
              _dateButton(
                label: '계약 종료일',
                value: _leaseEndDate,
                onTap: () => _pickDate(
                  current: _leaseEndDate,
                  onPicked: (value) => setState(() => _leaseEndDate = value),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text(
                    '수정 저장',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 24),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 22),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label 입력이 필요합니다.';
        }
        return null;
      },
    );
  }

  Widget _dateButton({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        onPressed: onTap,
        child: Text(
          '$label: ${_dateText(value)}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String _dateText(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
