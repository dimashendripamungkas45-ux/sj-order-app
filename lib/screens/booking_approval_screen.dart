import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../providers/role_provider.dart';

class BookingApprovalScreen extends StatefulWidget {
  final int bookingId;

  const BookingApprovalScreen({
    Key? key,
    required this.bookingId,
  }) : super(key: key);

  @override
  State<BookingApprovalScreen> createState() => _BookingApprovalScreenState();
}

class _BookingApprovalScreenState extends State<BookingApprovalScreen> {
  final _notesController = TextEditingController();
  Booking? _booking;
  bool _isApproving = false;

  @override
  void initState() {
    super.initState();
    _loadBookingDetail();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadBookingDetail() async {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    final booking = await provider.fetchBookingDetail(widget.bookingId);
    setState(() {
      _booking = booking;
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleApproval(String action) async {
    if (_isApproving) return;

    final provider = Provider.of<BookingProvider>(context, listen: false);
    final roleProvider = Provider.of<RoleProvider>(context, listen: false);
    final userRole = roleProvider.currentUser?.role;

    setState(() => _isApproving = true);

    try {
      bool success;
      String message;

      if (userRole == 'pimpinan_divisi') {
        // Tahap 1: Approval Divisi
        success = await provider.approveDivision(
          bookingId: widget.bookingId,
          action: action,
          notes: _notesController.text,
        );
        message = action == 'approve'
            ? 'Pemesanan disetujui dan diteruskan ke DIVUM'
            : 'Pemesanan ditolak oleh divisi';
      } else if (userRole == 'admin_divum') {
        // Tahap 2: Approval DIVUM
        success = await provider.approveDivum(
          bookingId: widget.bookingId,
          action: action,
          notes: _notesController.text,
        );
        message = action == 'approve'
            ? 'Pemesanan fully approved'
            : 'Pemesanan ditolak oleh DIVUM';
      } else {
        _showMessage('Anda tidak memiliki akses untuk approval', isError: true);
        return;
      }

      if (success) {
        _showMessage(message);
        // Reload booking detail
        await _loadBookingDetail();
      } else {
        _showMessage(provider.error ?? 'Gagal memproses approval', isError: true);
      }
    } catch (e) {
      print('Error during approval: $e');
      _showMessage('Error: $e', isError: true);
    } finally {
      setState(() => _isApproving = false);
    }
  }

  String _getApprovalStageLabel(String status, String userRole) {
    if (status == 'pending_division') {
      return 'Menunggu Persetujuan Pimpinan Divisi';
    } else if (status == 'pending_divum') {
      return 'Menunggu Persetujuan DIVUM';
    } else if (status == 'approved') {
      return 'Sudah Disetujui';
    } else if (status == 'rejected_division') {
      return 'Ditolak oleh Pimpinan Divisi';
    } else if (status == 'rejected_divum') {
      return 'Ditolak oleh DIVUM';
    }
    return 'Status Tidak Diketahui';
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

  bool _canApprove(String status, String userRole) {
    if (userRole == 'pimpinan_divisi') {
      return status == 'pending_division';
    } else if (userRole == 'admin_divum') {
      return status == 'pending_divum';
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final roleProvider = Provider.of<RoleProvider>(context);
    final userRole = roleProvider.currentUser?.role;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pemesanan & Approval'),
        elevation: 0,
        backgroundColor: const Color(0xFF00B477),
      ),
      body: _booking == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== STATUS CARD =====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_booking!.status).withValues(alpha: 0.1),
                      border: Border.all(
                        color: _getStatusColor(_booking!.status),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getStatusColor(_booking!.status),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getApprovalStageLabel(_booking!.status, userRole ?? ''),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(_booking!.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== BOOKING DETAILS =====
                  const Text(
                    'Detail Pemesanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'Kode Pemesanan',
                    _booking!.bookingCode,
                  ),
                  _buildDetailRow(
                    'Tipe',
                    _booking!.bookingType == 'room' ? 'Ruangan' : 'Kendaraan',
                  ),
                  _buildDetailRow(
                    'Sumber Daya',
                    _booking!.purpose,
                  ),
                  _buildDetailRow(
                    'Tanggal',
                    DateFormat('dd/MM/yyyy').format(
                      DateTime.parse(_booking!.bookingDate),
                    ),
                  ),
                  _buildDetailRow(
                    'Waktu',
                    '${_booking!.startTime} - ${_booking!.endTime}',
                  ),
                  if (_booking!.participantsCount != null)
                    _buildDetailRow(
                      'Jumlah Peserta',
                      _booking!.participantsCount.toString(),
                    ),
                  if (_booking!.destination != null)
                    _buildDetailRow(
                      'Tujuan',
                      _booking!.destination!,
                    ),
                  const SizedBox(height: 24),

                  // ===== APPROVAL HISTORY =====
                  const Text(
                    'Riwayat Persetujuan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildApprovalHistory(),
                  const SizedBox(height: 24),

                  // ===== APPROVAL FORM (if user can approve) =====
                  if (_canApprove(_booking!.status, userRole ?? ''))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catatan Persetujuan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: 'Masukkan catatan approval (optional)',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isApproving
                                    ? null
                                    : () => _handleApproval('reject'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                icon: const Icon(Icons.close),
                                label: const Text('Tolak'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isApproving
                                    ? null
                                    : () => _handleApproval('approve'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                icon: const Icon(Icons.check),
                                label: const Text('Setujui'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalHistory() {
    return Column(
      children: [
        // Tahap 1: Pimpinan Divisi
        _buildApprovalStepCard(
          step: 1,
          title: 'Persetujuan Pimpinan Divisi',
          isCompleted: _booking!.approvedByDivision != null,
          notes: _booking!.divisionApprovalNotes,
          timestamp: _booking!.status == 'pending_division' ? null : 'Sudah diproses',
        ),
        const SizedBox(height: 16),

        // Tahap 2: Admin DIVUM
        _buildApprovalStepCard(
          step: 2,
          title: 'Persetujuan Final DIVUM',
          isCompleted: _booking!.approvedByDivum != null,
          notes: _booking!.gaApprovalNotes,
          timestamp: _booking!.approvedByDivum != null ? 'Sudah diproses' : null,
        ),
      ],
    );
  }

  Widget _buildApprovalStepCard({
    required int step,
    required String title,
    required bool isCompleted,
    String? notes,
    String? timestamp,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isCompleted ? Colors.green : Colors.grey.shade300,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isCompleted ? Colors.green.shade50 : Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isCompleted ? Icons.check : Icons.pending,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (timestamp != null)
                      Text(
                        timestamp,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (notes != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                notes,
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

