import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_expense/database/database_service.dart';
import 'package:my_expense/screen/detail_report_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late Future<DateTime> _startDateFuture;

  @override
  void initState() {
    super.initState();
    _startDateFuture = DatabaseService.instance.getReportStartDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Reports'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<DateTime>(
        future: _startDateFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No start date set.'));
          }

          final startDate = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final reportMonth = DateTime(startDate.year, startDate.month + index, 1);
              return ReportCard(reportMonth: reportMonth);
            },
          );
        },
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final DateTime reportMonth;

  const ReportCard({Key? key, required this.reportMonth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format the date as "Month Year"
    final monthName = DateFormat('MMMM').format(reportMonth);
    final year = reportMonth.year;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 5,
        color: Colors.blueGrey[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Icon(
            Icons.calendar_today,
            color: Colors.blueGrey,
            size: 40,
          ),
          title: Text(
            '$monthName $year',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800],
            ),
          ),
          subtitle: Text(
            'Click to view detailed report',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blueGrey[600],
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailedReportScreen(reportMonth: reportMonth),
              ),
            );
          },
        ),
      ),
    );
  }
}
