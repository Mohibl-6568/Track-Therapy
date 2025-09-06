final List<PatientStructure> patients = [];

enum Gender { male, female, other }

class Entrystucture {
  final DateTime date;
  final int painlevel;
  final String description;
  Entrystucture({
    required this.date,
    required this.painlevel,
    required this.description,
  });
}

class PatientStructure {
  final String name;
  final int age;
  final Gender gender;
  final String diagnosis; // Default diagnosis
  final List<Entrystucture> entries;

  PatientStructure({
    required this.name,
    required this.age,
    required this.gender,
    required this.entries,
    required this.diagnosis,
  });

  void addEntry(Entrystucture entry) {
    entries.add(entry);
  }
}
