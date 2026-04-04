import 'package:flutter/material.dart';
import '../models/field.dart';
import '../services/field_service.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final Field? preselectedField;
  const BookingScreen({super.key, this.preselectedField});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Field> _fields = [];
  Field? _selectedField;
  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false;
  bool _loadingFields = true;

  @override
  void initState() {
    super.initState();
    _selectedField = widget.preselectedField;
    _loadFields();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFields() async {
    try {
      final fields = await FieldService.getAll();
      if (mounted) setState(() { _fields = fields; _loadingFields = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingFields = false);
    }
  }

  int get _durationHours {
    if (_startTime == null || _endTime == null) return 0;
    final diff = (_endTime!.hour * 60 + _endTime!.minute) - (_startTime!.hour * 60 + _startTime!.minute);
    return diff > 0 ? (diff / 60).ceil() : 0;
  }

  int get _totalPrice => _selectedField == null ? 0 : _selectedField!.pricePerHour * _durationHours;

  String _fmtPrice(int p) {
    final s = p.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if ((s.length - i) % 3 == 0 && i != 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _fmtTime(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _fmtDate(DateTime d) {
    const days = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? const TimeOfDay(hour: 8, minute: 0) : const TimeOfDay(hour: 10, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() { isStart ? _startTime = picked : _endTime = picked; });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null) { _showErr('Pilih tanggal booking.'); return; }
    if (_startTime == null || _endTime == null) { _showErr('Pilih jam mulai dan selesai.'); return; }
    if (_durationHours <= 0) { _showErr('Jam selesai harus lebih dari jam mulai.'); return; }

    setState(() => _isLoading = true);
    try {
      final booking = await BookingService.create(
        fieldId: _selectedField!.id,
        date: _date!,
        startTime: _fmtTime(_startTime!),
        endTime: _fmtTime(_endTime!),
        durationHours: _durationHours,
        totalPrice: _totalPrice,
      );
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(booking: booking)));
    } catch (e) {
      _showErr(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErr(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: AppColors.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Booking'), leading: const BackButton()),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepLabel(number: '1', label: 'Pilih Lapangan'),
              const SizedBox(height: 10),
              _loadingFields
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : DropdownButtonFormField<Field>(
                      value: _selectedField,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Lapangan',
                        prefixIcon: Icon(Icons.stadium_outlined, size: 20, color: AppColors.textHint),
                      ),
                      items: _fields.map((f) => DropdownMenuItem(
                        value: f,
                        child: Row(children: [
                          Expanded(child: Text(f.name, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis)),
                          if (!f.isAvailable) const Text(' (Penuh)', style: TextStyle(fontSize: 11, color: AppColors.warning)),
                        ]),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedField = v),
                      validator: (v) => v == null ? 'Pilih lapangan terlebih dahulu' : null,
                    ),
              const SizedBox(height: 20),
              const StepLabel(number: '2', label: 'Tanggal & Waktu'),
              const SizedBox(height: 10),
              // Date picker
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1.2),
                  ),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.textHint),
                    const SizedBox(width: 12),
                    Text(
                      _date != null ? _fmtDate(_date!) : 'Pilih tanggal booking',
                      style: TextStyle(fontSize: 14, color: _date != null ? AppColors.textPrimary : AppColors.textHint),
                    ),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textHint),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _timeTile('Jam Mulai', _startTime, () => _pickTime(true))),
                const SizedBox(width: 12),
                Expanded(child: _timeTile('Jam Selesai', _endTime, () => _pickTime(false))),
              ]),
              if (_durationHours > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.timer_outlined, color: AppColors.primary, size: 18),
                    const SizedBox(width: 10),
                    Text('Durasi: $_durationHours jam',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                  ]),
                ),
              ],
              const SizedBox(height: 20),
              const StepLabel(number: '3', label: 'Data Pemesan'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 20, color: AppColors.textHint),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'No. WhatsApp',
                  hintText: '08xxxxxxxxxx',
                  prefixIcon: Icon(Icons.phone_outlined, size: 20, color: AppColors.textHint),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nomor WA wajib diisi' : null,
              ),
              if (_totalPrice > 0) ...[
                const SizedBox(height: 20),
                _priceSummary(),
              ],
              const SizedBox(height: 20),
              PrimaryButton(label: 'Lanjut ke Pembayaran', icon: Icons.arrow_forward_rounded, isLoading: _isLoading, onPressed: _submit),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeTile(String label, TimeOfDay? time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1.2),
        ),
        child: Row(children: [
          const Icon(Icons.access_time_rounded, size: 18, color: AppColors.textHint),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
            Text(time != null ? _fmtTime(time) : '--:--',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: time != null ? AppColors.textPrimary : AppColors.textHint)),
          ]),
        ]),
      ),
    );
  }

  Widget _priceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Harga / jam', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text('Rp ${_fmtPrice(_selectedField?.pricePerHour ?? 0)}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ]),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Durasi', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text('$_durationHours jam', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ]),
        const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider()),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total Pembayaran',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text('Rp ${_fmtPrice(_totalPrice)}',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary)),
        ]),
      ]),
    );
  }
}
