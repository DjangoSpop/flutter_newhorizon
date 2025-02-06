import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final List<FinancialData> _data = [
    FinancialData(DateTime(2024, 1, 1), 150000),
    FinancialData(DateTime(2024, 2, 1), 230000),
    FinancialData(DateTime(2024, 3, 1), 320000),
    FinancialData(DateTime(2024, 4, 1), 275000),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Dashboard'),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMetricsRow(),
              const SizedBox(height: 20),
              _buildFinancialChart(),
              const SizedBox(height: 20),
              _buildRecentTransactions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildMetricCard('Total Revenue', '\$976,500', Icons.attach_money),
          const SizedBox(width: 10),
          _buildMetricCard('Pending Orders', '1,234', Icons.pending_actions),
          const SizedBox(width: 10),
          _buildMetricCard('Avg. Order Value', '\$245', Icons.assessment),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepPurpleAccent, size: 30),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w400)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Card(
      color: const Color(0xFF1A1A1A),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Recent Transactions',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DataTable(
              columns: [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Status')),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Text('Jan 1, 2024')),
                  DataCell(Text('\$150,000')),
                  DataCell(Text('Completed')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Feb 1, 2024')),
                  DataCell(Text('\$230,000')),
                  DataCell(Text('Completed')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Mar 1, 2024')),
                  DataCell(Text('\$320,000')),
                  DataCell(Text('Completed')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Apr 1, 2024')),
                  DataCell(Text('\$275,000')),
                  DataCell(Text('Completed')),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialChart() {
    return Card(
      color: const Color(0xFF1A1A1A),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Revenue Trend',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            DateFormat('MMM').format(_data[value.toInt()].date),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          );
                        },
                        interval: 1,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _data
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                              e.key.toDouble(), e.value.amount.toDouble()))
                          .toList(),
                      isCurved: true,
                      color: Colors.deepPurpleAccent,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                          show: true,
                          color: Colors.deepPurple.withOpacity(0.3)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FinancialData {
  final DateTime date;
  final int amount;

  FinancialData(this.date, this.amount);
}
