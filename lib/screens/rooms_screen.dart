import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({Key? key}) : super(key: key);

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  late Future<List<dynamic>> rooms;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  void _loadRooms() {
    setState(() {
      rooms = _fetchRooms();
    });
  }

  Future<List<dynamic>> _fetchRooms() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await ApiService.getRooms();
      if (response['success']) {
        return response['data'] ?? [];
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch rooms');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final capacityController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Ruangan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Ruangan'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Lokasi'),
              ),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(labelText: 'Kapasitas'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
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
                await ApiService.addRoom(
                  name: nameController.text,
                  location: locationController.text,
                  capacity: int.parse(capacityController.text),
                  description: descriptionController.text,
                );
                if (mounted) {
                  Navigator.pop(context);
                  _loadRooms();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ruangan berhasil ditambahkan')),
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
        title: const Text('Kelola Ruangan'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: rooms,
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
                    onPressed: _loadRooms,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final roomsList = snapshot.data as List<dynamic>;

          if (roomsList.isEmpty) {
            return const Center(
              child: Text('Tidak ada ruangan'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: roomsList.length,
            itemBuilder: (context, index) {
              final room = roomsList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.apartment),
                  title: Text(room['name'] ?? 'N/A'),
                  subtitle: Text(
                    '${room['location']} • Kapasitas: ${room['capacity']} orang',
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
                          await ApiService.deleteRoom(room['id']);
                          _loadRooms();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ruangan berhasil dihapus')),
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


