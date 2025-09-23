import 'dart:convert';

/// Class to import data for modules.
class ModuleModel {

  String key;
  String name;
  Uri infoUrl;
  int maxSeats;
  int takenSeats;
  String iconUrl;
  List<String>? restrictedModules;

  ModuleModel({
    required this.key,
    required this.name,
    required this.infoUrl,
    required this.maxSeats,
    required this.takenSeats,
    required this.iconUrl,
    this.restrictedModules
  });

  static List<ModuleModel> modulesFromJson(String str) => List<ModuleModel>.from(json.decode(str).map((x) => ModuleModel.fromJson(x)));

  factory ModuleModel.fromJson(Map<String, dynamic> jsonMap){

    /// Convert Map<String, dynamic> to ModuleModel object
    return ModuleModel(
        key: jsonMap["key"] as String,
        name: jsonMap["name"] as String,
        infoUrl: Uri.parse(jsonMap["infoUrl"] as String),
        maxSeats: jsonMap["seats"] as int,
        takenSeats: jsonMap["taken"] as int,
        iconUrl: jsonMap["icon"] as String,
        restrictedModules: jsonMap["exclusive"] as List<String>?
    );

  }

  @override
  String toString() {
    return '''{
      "key": $key,
      "name": "$name",
      "infoURL": "$infoUrl",
      "maxSeats": "$maxSeats",
      "maxSeats": "$takenSeats",
      "iconURL": "$iconUrl",
      "restrictedModules": "${restrictedModules.toString()}"
     }''';
  }
}