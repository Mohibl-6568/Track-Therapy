import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'patient_structure.dart';
import 'patientdetail.dart';

final patientsProvider = StateProvider<List<PatientStructure>>((ref) => []);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patients = ref.watch(patientsProvider);

    const Color primaryColor = Color(0xFF5D688A);
    const Color secondaryColor = Color(0xFFF7A5A5);
    const Color accentColor = Color(0xFFFFDBB6);
    const Color backgroundColor = Color(0xFFFFF2EF);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Patients',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: patients.isEmpty
          ? const Center(
              child: Text(
                'No patients added yet.',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
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
                      patient.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: primaryColor,
                      ),
                    ),
                    subtitle: Text(
                      'Age: ${patient.age} | Gender: ${patient.gender.name} \nDiagnosis: ${patient.diagnosis}',
                      style: const TextStyle(color: primaryColor),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PatientDetail(patient: patient),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: secondaryColor,
        onPressed: () {
          _showAddPatientModal(context, ref, primaryColor);
        },
        child: const Icon(Icons.add, color: primaryColor),
      ),
    );
  }

  void _showAddPatientModal(
    BuildContext context,
    WidgetRef ref,
    Color primaryColor,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String name = '';
        String age = '';
        String diagnosis = ''; // ✅ new variable
        Gender? gender;
        final genderOptions = Gender.values;

        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF2EF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add New Patient',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    labelText: 'Name',
                    onChanged: (value) => name = value,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    labelText: 'Age',
                    keyboardType: TextInputType.number,
                    onChanged: (value) => age = value,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    labelText: 'Diagnosis', // ✅ new field
                    onChanged: (value) => diagnosis = value,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 15),
                  _buildGenderDropdown(
                    gender: gender,
                    genderOptions: genderOptions,
                    onChanged: (value) => gender = value,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (name.isNotEmpty &&
                          age.isNotEmpty &&
                          diagnosis.isNotEmpty &&
                          gender != null) {
                        final newPatient = PatientStructure(
                          name: name,
                          age: int.parse(age),
                          gender: gender!,
                          diagnosis: diagnosis,
                          entries: [],
                        );
                        ref
                            .read(patientsProvider.notifier)
                            .update((state) => [...state, newPatient]);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7A5A5),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Patient',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D688A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
    required Color primaryColor,
  }) {
    return TextField(
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(color: primaryColor),
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
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown({
    required Gender? gender,
    required List<Gender> genderOptions,
    required Function(Gender?) onChanged,
    required Color primaryColor,
  }) {
    return DropdownButtonFormField<Gender>(
      value: gender,
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: TextStyle(color: primaryColor.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      dropdownColor: const Color(0xFFFFF2EF),
      items: genderOptions.map((g) {
        String genderText;
        switch (g) {
          case Gender.male:
            genderText = 'Male';
            break;
          case Gender.female:
            genderText = 'Female';
            break;
          case Gender.other:
            genderText = 'Other';
            break;
        }
        return DropdownMenuItem(
          value: g,
          child: Text(genderText, style: TextStyle(color: primaryColor)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
