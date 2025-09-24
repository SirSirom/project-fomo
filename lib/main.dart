import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:project_fomo/api/util/ApiHelper.dart';

void main() {
  runApp(const MyApp());
}

const String mockjsonDataString = '''
{
  "Course1": {
    "name": "Fotografie-Workshop",
    "infoUrl": "https://info.url",
    "seats": 20,
    "taken": 15,
    "icon": "https://icon.url",
    "exclusive": [
      "Option2"
    ]
  },
  "Course2": { 
    "name": "Videobearbeitungs-Kurs",
    "infoUrl": "https://info.url",
    "seats": 20,
    "taken": 10,
    "icon": "https://icon.url",
    "exclusive": [
      "Option1"
    ]
  },
  "Course3": {
    "name": "Grundlagen der Webentwicklung",
    "infoUrl": "https://info.url",
    "seats": 20,
    "taken": 12,
    "icon": "https://icon.url",
    "exclusive": [
    ]
    }
}
''';

class CourseOption {
  final String id;
  final String name;
  final int seats;
  final int taken;
  final List<String> exclusive;

  CourseOption({
    required this.id,
    required this.name,
    required this.seats,
    required this.taken,
    required this.exclusive,
  });

  // Eine "Factory"-Methode, um ein CourseOption-Objekt aus dem JSON zu erstellen.
  factory CourseOption.fromJson(String id, Map<String, dynamic> json) {
    return CourseOption(
      id: id,
      name: json['name'] ?? 'Unbenannter Kurs', //als Standard "Unbekannter Kurs"
      seats: json['seats'] ?? 0, //als Standard 0
      taken: json['taken'] ?? 0, //als Standard 0
      exclusive: List<String>.from(json['exclusive'] ?? []), //als Standard leer
    );
  }

  // Ein Helfer, um zu prüfen, ob der Kurs ausgebucht ist
  bool get isFull => taken >= seats;
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wahlpflichtkurswahl',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CourseSelectionScreen(),
    );
  }
}

class CourseSelectionScreen extends StatefulWidget {
  const CourseSelectionScreen({super.key});

  @override
  State<CourseSelectionScreen> createState() => _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
  // Liste aller verfügbaren Kurse
  List<CourseOption> _allOptions = [];
  // Ein Set, um die IDs der ausgewählten Kurse zu speichern.
  // Ein Set ist hier effizient, da es keine Duplikate erlaubt.
  final Set<String> _selectedOptionIds = {};
  final int _maxSelections = 2;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  // Lädt und parst die JSON-Daten.
  void _loadOptions() {
    final Map<String, dynamic> jsonData = json.decode(mockjsonDataString);
    setState(() {
      _allOptions = jsonData.entries.map((entry) {
        return CourseOption.fromJson(entry.key, entry.value);
      }).toList();
    });
  }

  // 3. Die Logik zur Verwaltung der Auswahl
  void _handleSelection(CourseOption option) {
    setState(() {
      // Wenn die Option bereits ausgewählt ist, wird sie abgewählt.
      if (_selectedOptionIds.contains(option.id)) {
        _selectedOptionIds.remove(option.id);
      } else {
        // Fügt die Option hinzu, wenn die Regeln es erlauben.
        _selectedOptionIds.add(option.id);
      }
    });
  }

  // Prüft, ob eine Option zur Auswahl zur Verfügung steht.
  bool _isOptionEnabled(CourseOption option) {
    // Bereits ausgewählte Optionen können immer abgewählt werden.
    if (_selectedOptionIds.contains(option.id)) {
      return true;
    }

    // Deaktiviere, wenn die Option ausgebucht ist.
    if (option.isFull) {
      return false;
    }

    // Deaktiviere, wenn das Maximum an Auswahlen erreicht ist.
    if (_selectedOptionIds.length >= _maxSelections) {
      return false;
    }

    // Deaktiviere, wenn eine exklusive Option bereits gewählt ist.
    for (String selectedId in _selectedOptionIds) {
      // Finde die bereits ausgewählte Option in der Gesamtliste.
      final selectedOption = _allOptions.firstWhere((opt) => opt.id == selectedId);
      // Prüfe in beide Richtungen auf Exklusivität.
      if (selectedOption.exclusive.contains(option.id) || option.exclusive.contains(selectedId)) {
        return false;
      }
    }

    return true; // Wenn keine Regel zutrifft, ist die Auswahl erlaubt.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      //app bar
      appBar: AppBar(
        title: const Text('Bitte wählen Sie Ihre Wahlpflichmodule aus.'),
      ),

      //body
      body: Column(
        children: [

          //x von x ausgewählt Text
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${_selectedOptionIds.length} von $_maxSelections Modulen ausgewählt',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),

          //liste der module
          Expanded(
            child: ListView.builder( //ListView war die simpleste umsetzung
              itemCount: _allOptions.length,
              itemBuilder: (context, index) {
                final option = _allOptions[index];
                final isSelected = _selectedOptionIds.contains(option.id);
                final isEnabled = _isOptionEnabled(option);

                // einzelnes modul
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  color: isEnabled ? Colors.white : Colors.grey[300],
                  child: ListTile(

                    // icon, TODO: ICON aus der übergebenen icon-URL nutzen (evtl)
                    leading: CircleAvatar(
                      backgroundColor: option.isFull ? Colors.red.shade100 : Colors.green.shade100,
                      child: Icon(
                        option.isFull ? Icons.do_not_disturb_on : Icons.check,
                        color: option.isFull ? Colors.red : Colors.green,
                      ),
                    ),

                    // titel
                    title: Text(option.name),

                    //anz. plätze
                    subtitle: Text(
                        option.isFull
                            ? 'Ausgebucht'
                            : 'Freie Plätze: ${option.seats - option.taken}'
                    ),

                    //selection checkbox
                    trailing: Checkbox(
                      value: isSelected,
                      // die checkbox wird deaktiviert indem onChanged auf null gesetzt wird
                      onChanged: isEnabled
                          ? (bool? value) => _handleSelection(option)
                          : null,
                    ),
                    // die gesamte kachel wird klickbar gemacht (TODO: gesamter Eintrag oder nur checkbox klickbar machen?)
                    onTap: isEnabled ? () => _handleSelection(option) : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}