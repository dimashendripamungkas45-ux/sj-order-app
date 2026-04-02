import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../providers/role_provider.dart';
import 'booking_approval_screen.dart';

class BookingListScreenWithApproval extends StatefulWidget {
  const BookingListScreenWithApproval({Key? key}) : super(key: key);

  @override
  State<BookingListScreenWithApproval> createState() => _BookingListScreenWithApprovalState();
}

class _BookingListScreenWithApprovalState extends State<BookingListScreenWithApproval> {
  @override
  void initState() {
    super.initState();
    // Fetch bookings saat screen di-load
    Future.microtask(() {
      Provider.of<BookingProvider>(context, listen: false).fetchBookings();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending_division':
      case 'pending_divum':
        return Colors.amber;
      case 'approved':
        return Colors.green;
      case 'rejected_division':
      case 'rejected_divum':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    return switch (status) {
      'pending_division' => 'Menunggu Divisi',
      'pending_divum' => 'Menunggu DIVUM',
      'approved' => 'Disetujui',
      'rejected_division' => 'Ditolak Divisi',
      'rejected_divum' => 'Ditolak DIVUM',
      _ => 'Unknown',
    };
  }

  bool _canApprove(Booking booking, String userRole) {
    if (userRole == 'pimpinan_divisi') {
      return booking.status == 'pending_division';
    } else if (userRole == 'admin_divum') {
      return booking.status == 'pending_divum';
    }
    return false;
  }

  void _showApprovalBottomSheet(Booking booking, String userRole) {
    final notesController = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Persetujuan Pemesanan',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kode: ${booking.bookingCode}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Catatan (optional)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    setState(() => isLoading = true);
                                    final provider = Provider.of<BookingProvider>(
                                      context,
                                      listen: false,
                                    );

                                    bool success;
                                    if (userRole == 'pimpinan_divisi') {
                                      success = await provider.approveDivision(
                                        bookingId: booking.id,
                                        action: 'reject',
                                        notes: notesController.text,
                                      );
                                    } else {
                                      success = await provider.approveDivum(
                                        bookingId: booking.id,
                                        action: 'reject',
                                        notes: notesController.text,
                                      );
                                    }

                                    if (mounted) {
                                      Navigator.pop(context);
                                      if (success) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Pemesanan ditolak'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                      setState(() => isLoading = false);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Tolak'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    setState(() => isLoading = true);
                                    final provider = Provider.of<BookingProvider>(
                                      context,
                                      listen: false,
                                    );

                                    bool success;
                                    if (userRole == 'pimpinan_divisi') {
                                      success = await provider.approveDivision(
                                        bookingId: booking.id,
                                        action: 'approve',
                                        notes: notesController.text,
                                      );
                                    } else {
                                      success = await provider.approveDivum(
                                        bookingId: booking.id,
                                        action: 'approve',
                                        notes: notesController.text,
                                      );
                                    }

                                    if (mounted) {
                                      Navigator.pop(context);
                                      if (success) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Pemesanan disetujui'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                      setState(() => isLoading = false);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('Setujui'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final roleProvider = Provider.of<RoleProvider>(context);
    final userRole = roleProvider.currentUser?.role ?? 'user';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pemesanan'),
        backgroundColor: const Color(0xFF00B477),
        elevation: 0,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, _) {
          if (bookingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookingProvider.bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada pemesanan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => bookingProvider.refreshBookings(),
            child: ListView.builder(
              itemCount: bookingProvider.bookings.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final booking = bookingProvider.bookings[index];
                final canApprove = _canApprove(booking, userRole);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  child: Column(
                    children: [
                      // Header dengan kode & status
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: _getStatusColor(booking.status).withValues(alpha: 0.1),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kode: ${booking.bookingCode}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(booking.status),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _getStatusLabel(booking.status),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (canApprove)
                              IconButton(
                                onPressed: () => _showApprovalBottomSheet(booking, userRole),
                                icon: const Icon(Icons.check_circle_outline),
                                color: Colors.green,
                              )
                            else
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => BookingApprovalScreen(
                                        bookingId: booking.id,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.info_outline),
                                color: Colors.blue,
                              ),
                          ],
                        ),
                      ),
                      // Detail Pemesanan
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                              'Tipe',
                              booking.bookingType == 'room' ? '🏢 Ruangan' : '🚗 Kendaraan',
                            ),
                            _buildDetailRow(
                              'Tujuan',
                              booking.purpose,
                            ),
                            _buildDetailRow(
                              'Tanggal',
                              DateFormat('dd MMM yyyy').format(
                                DateTime.parse(booking.bookingDate),
                              ),
                            ),
                            _buildDetailRow(
                              'Waktu',
                              '${booking.startTime} - ${booking.endTime}',
                            ),
                            if (booking.participantsCount != null)
                              _buildDetailRow(
                                'Peserta',
                                '${booking.participantsCount} orang',
                              ),
                            if (booking.destination != null)
                              _buildDetailRow(
                                'Tujuan',
                                booking.destination!,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

