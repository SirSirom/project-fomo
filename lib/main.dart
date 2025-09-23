import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:project_fomo/api/util/ApiHelper.dart';

void main() {
  runApp(const MyApp());
}

const String mockjsonDataString = '''
{
  "Option1": {
    "name": "Fotografie-Workshop",
    "infoUrl": "https://info.url",
    "seats": 20,
    "taken": 15,
    "icon": "https://icon.url",
    "exclusive": [
      "Option2"
    ]
  },
  "Option2": { 
    "name": "Videobearbeitungs-Kurs",
    "infoUrl": "https://info.url",
    "seats": 20,
    "taken": 10,
    "icon": "https://icon.url",
    "exclusive": [
      "Option1"
    ]
  },
  "Option3": {
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

  // Eine "Factory"-Methode, um ein CourseOption-Objekt aus JSON zu erstellen.
  factory CourseOption.fromJson(String id, Map<String, dynamic> json) {
    return CourseOption(
      id: id,
      name: json['name'] ?? 'Unbenannte Option',
      seats: json['seats'] ?? 0,
      taken: json['taken'] ?? 0,
      exclusive: List<String>.from(json['exclusive'] ?? []),
    );
  }

  // Ein Helfer, um zu prüfen, ob die Option ausgebucht ist.
  bool get isFull => taken >= seats;
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Optionsauswahl',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const OptionSelectionScreen(),
    );
  }
}

class OptionSelectionScreen extends StatefulWidget {
  const OptionSelectionScreen({super.key});

  @override
  State<OptionSelectionScreen> createState() => _OptionSelectionScreenState();
}

class _OptionSelectionScreenState extends State<OptionSelectionScreen> {
  // Liste aller verfügbaren Optionen
  List<CourseOption> _allOptions = [];
  // Ein Set, um die IDs der ausgewählten Optionen zu speichern.
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
      appBar: AppBar(
        title: const Text('Wähle bis zu 2 Optionen'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${_selectedOptionIds.length} von $_maxSelections ausgewählt',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _allOptions.length,
              itemBuilder: (context, index) {
                final option = _allOptions[index];
                final isSelected = _selectedOptionIds.contains(option.id);
                final isEnabled = _isOptionEnabled(option);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  color: isEnabled ? Colors.white : Colors.grey[300],
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: option.isFull ? Colors.red.shade100 : Colors.green.shade100,
                      child: Icon(
                        option.isFull ? Icons.do_not_disturb_on : Icons.check,
                        color: option.isFull ? Colors.red : Colors.green,
                      ),
                    ),
                    title: Text(option.name),
                    subtitle: Text(
                        option.isFull
                            ? 'Ausgebucht'
                            : 'Freie Plätze: ${option.seats - option.taken}'
                    ),
                    trailing: Checkbox(
                      value: isSelected,
                      // Das Checkbox wird deaktiviert, indem onChanged auf null gesetzt wird.
                      onChanged: isEnabled
                          ? (bool? value) => _handleSelection(option)
                          : null,
                    ),
                    // Die gesamte Kachel wird klickbar gemacht.
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      ApiHelper.loadModules(4).then((value) {
        value.forEach((module) {
          print(module.toString());
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
