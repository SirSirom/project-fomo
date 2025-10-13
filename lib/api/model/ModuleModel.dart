import 'dart:convert';

/// Class to import data for modules.
class ModuleModel {

  String key;
  String name;
  String description;
  int maxSeats;
  int takenSeats;
  String iconUrl;
  List<String>? restrictedModules;

  ModuleModel({
    required this.key,
    required this.name,
    required this.description,
    required this.maxSeats,
    required this.takenSeats,
    required this.iconUrl,
    this.restrictedModules
  });

  static List<ModuleModel> modulesFromJson(String str) => List<ModuleModel>.from(json.decode(str).map((x) => ModuleModel.fromJson(x)));

  factory ModuleModel.fromJson(Map<String, dynamic> jsonMap) {

    /// Convert Map<String, dynamic> to ModuleModel object
    return ModuleModel(
        key: jsonMap["key"] as String,
        name: jsonMap["name"] as String,
        description: jsonMap["description"] as String,
        maxSeats: jsonMap["seats"] as int,
        takenSeats: jsonMap["taken"] as int,
        iconUrl: jsonMap["icon"] as String,
        restrictedModules: (jsonMap["exclusive"] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList()
    );

  }

  @override
  String toString() {
    return '''{
      "key": $key,
      "name": "$name",
      "description": "$description",
      "maxSeats": "$maxSeats",
      "takenSeats": "$takenSeats",
      "iconURL": "$iconUrl",
      "restrictedModules": "${restrictedModules.toString()}"
     }''';
  }

  bool get isFull => maxSeats <= takenSeats;
}