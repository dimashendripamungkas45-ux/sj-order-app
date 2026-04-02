import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({Key? key}) : super(key: key);

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  late Future<List<dynamic>> vehicles;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  void _loadVehicles() {
    setState(() {
      vehicles = _fetchVehicles();
    });
  }

  Future<List<dynamic>> _fetchVehicles() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await ApiService.getVehicles();
      if (response['success']) {
        return response['data'] ?? [];
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch vehicles');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final licensePlateController = TextEditingController();
    final typeController = TextEditingController();
    final capacityController = TextEditingController();
    final driverNameController = TextEditingController();
    final driverPhoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kendaraan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Kendaraan'),
              ),
              TextField(
                controller: licensePlateController,
                decoration: const InputDecoration(labelText: 'Plat Nomor'),
              ),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Tipe'),
              ),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(labelText: 'Kapasitas'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: driverNameController,
                decoration: const InputDecoration(labelText: 'Nama Driver'),
              ),
              TextField(
                controller: driverPhoneController,
                decoration: const InputDecoration(labelText: 'No. HP Driver'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() => isLoading = true);
              try {
                await ApiService.addVehicle(
                  name: nameController.text,
                  licensePlate: licensePlateController.text,
                  type: typeController.text,
                  capacity: int.parse(capacityController.text),
                  driverName: driverNameController.text,
                  driverPhone: driverPhoneController.text,
                );
                if (mounted) {
                  Navigator.pop(context);
                  _loadVehicles();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kendaraan berhasil ditambahkan')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              } finally {
                setState(() => isLoading = false);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kendaraan'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: vehicles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadVehicles,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final vehiclesList = snapshot.data as List<dynamic>;

          if (vehiclesList.isEmpty) {
            return const Center(
              child: Text('Tidak ada kendaraan'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vehiclesList.length,
            itemBuilder: (context, index) {
              final vehicle = vehiclesList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: Text(vehicle['name'] ?? 'N/A'),
                  subtitle: Text(
                    '${vehicle['license_plate']} • ${vehicle['type']} • ${vehicle['capacity']} orang',
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Hapus'),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'delete') {
                        setState(() => isLoading = true);
                        try {
                          await ApiService.deleteVehicle(vehicle['id']);
                          _loadVehicles();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Kendaraan berhasil dihapus')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        } finally {
                          setState(() => isLoading = false);
                        }
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


