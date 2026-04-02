import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class AdminVehicleManagementScreen extends StatefulWidget {
  @override
  State<AdminVehicleManagementScreen> createState() => _AdminVehicleManagementScreenState();
}

class _AdminVehicleManagementScreenState extends State<AdminVehicleManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _capacityController;
  late TextEditingController _licensePlateController;
  late TextEditingController _driverNameController;
  late TextEditingController _driverPhoneController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _typeController = TextEditingController();
    _capacityController = TextEditingController();
    _licensePlateController = TextEditingController();
    _driverNameController = TextEditingController();
    _driverPhoneController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _capacityController.dispose();
    _licensePlateController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<AdminProvider>(context, listen: false);

    final vehicleData = {
      'name': _nameController.text,
      'type': _typeController.text,
      'capacity': int.parse(_capacityController.text),
      'license_plate': _licensePlateController.text,
      'driver_name': _driverNameController.text,
      'driver_phone': _driverPhoneController.text,
      'description': _descriptionController.text,
    };

    final success = await provider.createVehicle(vehicleData);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Kendaraan berhasil ditambahkan!')),
      );
      _formKey.currentState!.reset();
      _nameController.clear();
      _typeController.clear();
      _capacityController.clear();
      _licensePlateController.clear();
      _driverNameController.clear();
      _driverPhoneController.clear();
      _descriptionController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: ${provider.errorMessage}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Kendaraan'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 16),
              Text('Tambah Kendaraan Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Kendaraan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Nama kendaraan harus diisi' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(
                  labelText: 'Tipe Kendaraan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                  hintText: 'Contoh: Mobil, Motor, Bus',
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Tipe harus diisi' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: InputDecoration(
                  labelText: 'Kapasitas Penumpang',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Kapasitas harus diisi' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _licensePlateController,
                decoration: InputDecoration(
                  labelText: 'Plat Nomor',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.confirmation_number),
                  hintText: 'Contoh: B 1234 CD',
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Plat nomor harus diisi' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _driverNameController,
                decoration: InputDecoration(
                  labelText: 'Nama Supir (Opsional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _driverPhoneController,
                decoration: InputDecoration(
                  labelText: 'No. Telepon Supir (Opsional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  hintText: '081234567890',
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              Consumer<AdminProvider>(
                builder: (context, provider, _) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: provider.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('✅ Tambah Kendaraan', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

