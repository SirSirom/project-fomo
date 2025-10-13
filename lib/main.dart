import 'package:flutter/material.dart';
import 'package:project_fomo/api/model/ModuleModel.dart';
import 'dart:convert';
import 'package:project_fomo/api/util/ApiHelper.dart';

void main() {
  runApp(const MyApp());
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
  List<ModuleModel> _allModuleOptions = [];
  // Ein Set, um die IDs der ausgewählten Kurse zu speichern.
  // Ein Set ist hier effizient, da es keine Duplikate erlaubt.
  final Set<String> _selectedModuleKeys = {};
  final int _maxSelections = 2;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  // Lädt und parst die JSON-Daten.
  Future<void> _loadOptions() async {
    List<ModuleModel> modules = await ApiHelper.loadModules(4);
    setState(() {
      _allModuleOptions = modules;
    });
  }

  // 3. Die Logik zur Verwaltung der Auswahl
  void _handleSelection(ModuleModel module) {
    setState(() {
      // Wenn die Option bereits ausgewählt ist, wird sie abgewählt.
      if (_selectedModuleKeys.contains(module.key)) {
        _selectedModuleKeys.remove(module.key);
      } else {
        // Fügt die Option hinzu, wenn die Regeln es erlauben.
        _selectedModuleKeys.add(module.key);
      }
    });
  }

  // Prüft, ob eine Option zur Auswahl zur Verfügung steht.
  bool _isOptionEnabled(ModuleModel module) {
    // Bereits ausgewählte Optionen können immer abgewählt werden.
    if (_selectedModuleKeys.contains(module.key)) {
      return true;
    }

    // Deaktiviere, wenn die Option ausgebucht ist.
    if (module.isFull) {
      return false;
    }

    // Deaktiviere, wenn das Maximum an Auswahlen erreicht ist.
    if (_selectedModuleKeys.length >= _maxSelections) {
      return false;
    }

    // Deaktiviere, wenn eine exklusive Option bereits gewählt ist.
    for (String selectedKey in _selectedModuleKeys) {
      // Finde die bereits ausgewählte Option in der Gesamtliste.
      final selectedModule = _allModuleOptions.firstWhere((opt) => opt.key == selectedKey);
      // Prüfe in beide Richtungen auf Exklusivität.
      if ((selectedModule.restrictedModules?.contains(module.key) ?? true) || (module.restrictedModules?.contains(selectedKey) ?? true)) {
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
              '${_selectedModuleKeys.length} von $_maxSelections Modulen ausgewählt',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),

          //liste der module
          Expanded(
            child: ListView.builder( //ListView war die simpleste umsetzung
              itemCount: _allModuleOptions.length,
              itemBuilder: (context, index) {
                final moduleOption = _allModuleOptions[index];
                final isSelected = _selectedModuleKeys.contains(moduleOption.key);
                final isEnabled = _isOptionEnabled(moduleOption);

                // einzelnes modul
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  color: isEnabled ? Colors.white : Colors.grey[300],
                  child: ListTile(

                    // icon, TODO: ICON aus der übergebenen icon-URL nutzen (evtl)
                    leading: CircleAvatar(
                      backgroundColor: moduleOption.isFull ? Colors.red.shade100 : Colors.green.shade100,
                      child: Icon(
                        moduleOption.isFull ? Icons.do_not_disturb_on : Icons.check,
                        color: moduleOption.isFull ? Colors.red : Colors.green,
                      ),
                    ),

                    // titel
                    title: Text(moduleOption.name),

                    //anz. plätze
                    subtitle: Text(
                        moduleOption.isFull
                            ? 'Ausgebucht'
                            : 'Freie Plätze: ${moduleOption.maxSeats - moduleOption.takenSeats}'
                    ),

                    // Info-Button + Checkbox
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.info_outline, color: Color.fromARGB(255, 72, 113, 59)),
                          tooltip: 'Mehr Informationen',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),

                                titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),

                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        moduleOption.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        moduleOption.iconUrl,
                                        width: 128,
                                        height: 128,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      moduleOption.isFull
                                          ? 'Dieses Modul ist derzeit ausgebucht.'
                                          : 'Freie Plätze: ${moduleOption.maxSeats - moduleOption.takenSeats}\n'
                                          'Maximale Plätze: ${moduleOption.maxSeats}',
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      moduleOption.description,
                                      style: const TextStyle(color: Colors.black87),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Schließen'),
                                  ),
                                ],
                              ),
                            );
                          }),
                        Checkbox(
                          value: isSelected,
                          onChanged: isEnabled
                              ? (bool? value) => _handleSelection(moduleOption)
                              : null,
                        ),
                      ],
                    ),

                    // die gesamte kachel wird klickbar gemacht (TODO: gesamter Eintrag oder nur checkbox klickbar machen?)
                    onTap: isEnabled ? () => _handleSelection(moduleOption) : null,
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