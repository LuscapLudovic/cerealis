import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';

class ApiService {
  static final String apiUrl = "192.168.1.54:8008";

  static Future<dynamic> post({required String url, data}) async {
    http.Response resp = await http.post(Uri.http(apiUrl, "/api" + url),
        headers: {
          HttpHeaders.acceptEncodingHeader: "application/json",
        },
        body: data);

    print(resp.body);
    if (resp.statusCode == 200)
      return jsonDecode(resp.body);
    throw "Can't post.";
  }

  static Future<bool> postUser({required String name, required String email}) async {
    dynamic response = await ApiService.post(url: "/customer", data: {
      'name': name,
      'email': email
    });
    return (response != Null);
  }

}


