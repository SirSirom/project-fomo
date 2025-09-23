import 'package:http/http.dart' as http;

import '../model/ModuleModel.dart';

/**
 * Class to handle api requests
 */
class ApiHelper {
  /// Sets the endpoint for the api
  static String endpoint = "https://9e6a81ff-13d1-4920-83ab-996b086446d2.mock.pstmn.io/";

  static Future<http.Response> sendRequest(String uri,HttpMethod httpMethod,{Map<String, String>? additionalHeaders,Object? postBody}) async {
    ///Handle Requests
    switch (httpMethod){
      case HttpMethod.POST:
        return await http.post(
            Uri.parse('$endpoint$uri'),
            headers: additionalHeaders,
            body: postBody);
      case HttpMethod.GET:
        return await http.get(
            Uri.parse('$endpoint$uri'),
            headers: additionalHeaders
        );
    }
  }

  static Future<List<ModuleModel>> loadModules(int season) async {
    ///send Request and Parse by method from ModuleModel
    String body = await sendRequest('s$season', HttpMethod.GET).then((value) => value.body);
    return ModuleModel.modulesFromJson((await sendRequest('s$season', HttpMethod.GET)).body);
  }

}

///enum to handle Http Methods
enum HttpMethod{ POST,GET}