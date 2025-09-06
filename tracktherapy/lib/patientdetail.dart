import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'patient_structure.dart';

class PatientDetail extends StatefulWidget {
  final PatientStructure patient;

  const PatientDetail({super.key, required this.patient});

  @override
  State<PatientDetail> createState() => _PatientDetailState();
}

class _PatientDetailState extends State<PatientDetail> {
  static const Color primaryColor = Color(0xFF5D688A);
  static const Color secondaryColor = Color(0xFFF7A5A5);
  static const Color accentColor = Color(0xFFFFDBB6);
  static const Color backgroundColor = Color(0xFFFFF2EF);

  void _openAddEntryModal(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String description = '';
    int condition = 0;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add New Entry',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(
                      labelText: 'Pain Level (0-10)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a pain level';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number < 0 || number > 10) {
                          return 'Pain level must be between 0 and 10';
                        }
                        return null;
                      },
                      onSaved: (value) => condition = int.parse(value!),
                    ),
                    const SizedBox(height: 15),
                    _buildTextFormField(
                      labelText: 'Description',
                      maxLines: 3,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter a description'
                          : null,
                      onSaved: (value) => description = value!,
                    ),
                    const SizedBox(height: 15),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return Row(
                          children: [
                            Text(
                              "Date: ${selectedDate.toLocal().toString().split(' ')[0]}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    builder: (context, child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          colorScheme: const ColorScheme.light(
                                            primary: primaryColor,
                                            onPrimary: Colors.white,
                                            onSurface: primaryColor,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      selectedDate = picked;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: secondaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Pick Date',
                                  style: TextStyle(color: primaryColor),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          final newEntry = Entrystucture(
                            date: selectedDate,
                            painlevel: condition,
                            description: description,
                          );
                          setState(() {
                            widget.patient.entries.add(newEntry);
                          });
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Entry',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextFormField({
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: primaryColor.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onSaved: onSaved,
      style: const TextStyle(color: primaryColor),
    );
  }

  LineChartData _buildChartData() {
    if (widget.patient.entries.isEmpty) {
      return LineChartData(
        minX: 0,
        maxX: 1,
        minY: 0,
        maxY: 10,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [LineChartBarData(spots: [])],
      );
    }

    final spots = widget.patient.entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.painlevel.toDouble());
    }).toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: primaryColor.withOpacity(0.2), strokeWidth: 1);
        },
        drawVerticalLine: true,
        getDrawingVerticalLine: (value) {
          return FlLine(color: primaryColor.withOpacity(0.2), strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index >= 0 && index < widget.patient.entries.length) {
                final date = widget.patient.entries[index].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "${date.day}/${date.month}",
                    style: const TextStyle(fontSize: 10, color: primaryColor),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(color: primaryColor, fontSize: 12),
              );
            },
            interval: 2,
            reservedSize: 28,
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: primaryColor.withOpacity(0.5), width: 1),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: primaryColor,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: secondaryColor,
                strokeColor: primaryColor,
                strokeWidth: 2,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: primaryColor.withOpacity(0.2),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (spots) => primaryColor.withOpacity(0.8),
          getTooltipItems: (List<FlSpot> touchedSpots) {
            return touchedSpots.map((FlSpot touchedSpot) {
              final entry = widget.patient.entries[touchedSpot.x.toInt()];
              return LineTooltipItem(
                'Date: ${entry.date.toLocal().toString().split(' ')[0]}\nPain: ${entry.painlevel}',
                const TextStyle(color: accentColor),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(widget.patient.name),
        backgroundColor: primaryColor,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: widget.patient.entries.isEmpty
          ? const Center(
              child: Text(
                'No entries available.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(12.0),
              children: [
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Patient Entries',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ...widget.patient.entries.map((entry) {
                  return Card(
                    color: accentColor,
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      title: Text(
                        'Date: ${entry.date.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            'Pain level: ${entry.painlevel}',
                            style: const TextStyle(color: primaryColor),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Description: ${entry.description}',
                            style: const TextStyle(color: primaryColor),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    'Pain Level Chart',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(height: 250, child: LineChart(_buildChartData())),
                const SizedBox(height: 20),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEntryModal(context),
        backgroundColor: secondaryColor,
        child: const Icon(Icons.add, color: primaryColor),
      ),
    );
  }
}
