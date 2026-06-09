import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/kiosk_viewmodel.dart';
import 'kiosk_payment_view.dart';
import '../../../core/constants/app_theme.dart';

class KioskFormView extends StatefulWidget {
  const KioskFormView({super.key});

  @override
  State<KioskFormView> createState() => _KioskFormViewState();
}

class _KioskFormViewState extends State<KioskFormView> {
  final _nameController = TextEditingController();
  final _nikController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _gender = 'Laki-laki';
  DateTime? _birthDate;
  String _passengerType = 'Dewasa';
  String _nationality = 'WNI';
  String _specialCondition = 'Tidak Ada';

  bool _isNikValid = false;
  
  bool get _isValid => 
    _isNikValid && 
    _nameController.text.isNotEmpty && 
    _birthPlaceController.text.isNotEmpty && 
    _birthDate != null && 
    _phoneController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nikController.addListener(() {
      setState(() {
        _isNikValid = _nikController.text.length == 16;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _birthPlaceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
  }

  Widget _buildDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<KioskViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 40, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Formulir Data Penumpang',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Container(
            width: 1000,
            padding: const EdgeInsets.all(60),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text(
                'Sesuai aturan pelabuhan, mohon lengkapi data diri Anda dengan benar.',
                style: TextStyle(fontSize: 20, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 60),
              
              // Nama Lengkap
              const Text('Nama Lengkap (Sesuai KTP)', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'Contoh: Budi Santoso',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 3),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 48),

              // NIK
              const Text('Nomor Induk Kependudukan (NIK)', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _nikController,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                decoration: InputDecoration(
                  hintText: '16 Digit NIK Anda',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 3),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      '${_nikController.text.length}/16',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _isNikValid ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),

              // Jenis Kelamin & Jenis Penumpang
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Jenis Kelamin'),
                        const SizedBox(height: 16),
                        _buildDropdown(_gender, ['Laki-laki', 'Perempuan'], (v) {
                          if (v != null) setState(() => _gender = v);
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Jenis Penumpang'),
                        const SizedBox(height: 16),
                        _buildDropdown(_passengerType, ['Dewasa', 'Anak (2-12 tahun)', 'Bayi (< 2 tahun)'], (v) {
                          if (v != null) setState(() => _passengerType = v);
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),

              // Tempat & Tanggal Lahir
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Tempat Lahir'),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _birthPlaceController,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            hintText: 'Contoh: Jakarta',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Tanggal Lahir'),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _birthDate == null 
                                    ? 'Pilih Tanggal' 
                                    : '${_birthDate!.day.toString().padLeft(2,'0')}/${_birthDate!.month.toString().padLeft(2,'0')}/${_birthDate!.year}',
                                  style: TextStyle(
                                    fontSize: 28, 
                                    fontWeight: FontWeight.bold, 
                                    color: _birthDate == null ? Colors.grey.shade400 : Colors.black,
                                  ),
                                ),
                                const Icon(Icons.calendar_today, size: 32),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Kewarganegaraan & Kondisi Khusus
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Kewarganegaraan'),
                        const SizedBox(height: 16),
                        _buildDropdown(_nationality, ['WNI', 'WNA'], (v) {
                          if (v != null) setState(() => _nationality = v);
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Kondisi Khusus'),
                        const SizedBox(height: 16),
                        _buildDropdown(_specialCondition, ['Tidak Ada', 'Lansia', 'Disabilitas', 'Ibu Hamil'], (v) {
                          if (v != null) setState(() => _specialCondition = v);
                        }),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Nomor Telepon & Nomor Kursi
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Nomor Telepon'),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _phoneController,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            hintText: '081234567890',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Nomor Kursi'),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.primary.withAlpha(100)),
                          ),
                          child: Text(
                            vm.selectedSeat ?? '-',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 60),
              
              SizedBox(
                width: double.infinity,
                height: 90,
                child: ElevatedButton(
                  onPressed: _isValid
                      ? () {
                          vm.setPassengerData(
                            name: _nameController.text, 
                            nik: _nikController.text,
                            gender: _gender,
                            birthPlace: _birthPlaceController.text,
                            birthDate: _birthDate!.toIso8601String(),
                            phone: _phoneController.text,
                            type: _passengerType,
                            nationality: _nationality,
                            condition: _specialCondition,
                          );
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const KioskPaymentView(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text(
                    'Lanjut ke Pembayaran',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
