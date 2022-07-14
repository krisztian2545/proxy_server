import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

const String redirectHost = "192.168.201.8";

void respond(HttpRequest request, Response response) {
  request.response.write(response.body);
  request.response.close();
}

Map<String, String> headerToMap(HttpHeaders header) {
  var parsed = <String, String>{};

  header.forEach((name, values) => parsed[name] = values.join(""));

  return parsed;
}

Uri uriToDestinationUri(Uri uri) => uri.replace(
      scheme: 'http',
      port: 80,
      host: redirectHost,
    );

void main() async {
  var server = await HttpServer.bind('192.168.241.227', 80);
  await server.forEach((HttpRequest request) {
    utf8.decodeStream(request).then((data) {
      var method = request.method;
      print(
          "request: ${request.uri.replace(scheme: 'http', host: redirectHost)}");
      print("header: ${request.headers.toString()}");
      print("data: $data");

      if (method == 'GET') {
        var parsedHeader = headerToMap(request.headers);
        print("parsed header: ${parsedHeader}");

        get(
          uriToDestinationUri(request.uri),
          headers: parsedHeader,
        ).then((res) {
          print("response: ${res.body}");
          respond(request, res);
        });
      } else if (method == 'POST') {
        var parsedHeader = headerToMap(request.headers);
        print("parsed header: ${parsedHeader}");

        post(
          uriToDestinationUri(request.uri),
          headers: parsedHeader,
          body: data,
        ).then((res) {
          print("response: ${res.body}");
          respond(request, res);
        });
      }
    });
  });
}
