import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/report_repository.dart';
import '../domain/field_report.dart';

/// Page displaying all captured reports with sync status
class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  List<FieldReport> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final reportRepo = ref.read(reportRepositoryProvider);
    final reports = await reportRepo.getReports(userId);

    setState(() {
      _reports = reports;
      _isLoading = false;
    });
  }

  Future<void> _retrySync(FieldReport report) async {
    final reportRepo = ref.read(reportRepositoryProvider);
    await reportRepo.retrySyncReport(report.id);
    await _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports'), centerTitle: true),
      body: RefreshIndicator(onRefresh: _loadReports, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No reports yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Capture your first field report!', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        return _ReportListItem(report: _reports[index], onRetry: () => _retrySync(_reports[index]));
      },
    );
  }
}

class _ReportListItem extends StatelessWidget {
  final FieldReport report;
  final VoidCallback onRetry;

  const _ReportListItem({required this.report, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showReportDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(report.imageBytes, width: 60, height: 60, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_formatDate(report.capturedAt), style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      _formatLocation(report.latitude, report.longitude),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hash: ${report.dataHash.substring(0, 12)}...',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500], fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
              // Sync status
              _buildSyncStatus(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncStatus() {
    switch (report.syncStatus) {
      case SyncStatus.synced:
        return const Tooltip(message: 'Synced', child: Icon(Icons.cloud_done, color: Colors.green));
      case SyncStatus.pending:
        return const Tooltip(message: 'Pending sync', child: Icon(Icons.cloud_upload_outlined, color: Colors.orange));
      case SyncStatus.syncing:
        return const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
      case SyncStatus.failed:
        return IconButton(
          icon: const Icon(Icons.error_outline, color: Colors.red),
          tooltip: 'Sync failed - tap to retry',
          onPressed: onRetry,
        );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatLocation(double lat, double long) {
    final latDir = lat >= 0 ? 'N' : 'S';
    final longDir = long >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(4)}°$latDir, ${long.abs().toStringAsFixed(4)}°$longDir';
  }

  void _showReportDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder:
                (context, scrollController) => SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(report.imageBytes, fit: BoxFit.contain),
                        ),
                        const SizedBox(height: 16),
                        _detailRow('Captured', _formatDate(report.capturedAt)),
                        _detailRow('Location', _formatLocation(report.latitude, report.longitude)),
                        _detailRow('Status', report.syncStatus.name.toUpperCase()),
                        _detailRow('Hash', report.dataHash),
                        if (report.remoteId != null) _detailRow('Remote ID', report.remoteId!),
                        if (report.errorMessage != null) _detailRow('Error', report.errorMessage!, isError: true),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  Widget _detailRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isError ? Colors.red : null,
              fontFamily: label == 'Hash' || label == 'Remote ID' ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }
}
