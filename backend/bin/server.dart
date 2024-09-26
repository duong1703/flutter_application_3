import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

//Config header
final _headers = {'Content-Type': 'application/json'};

// Configure routes.
final _router = Router(notFoundHandler: _notFoundHandler)
  ..get('/', _rootHandler)
  ..get('/api/v1/check', _checkHandler)
  ..get('/api/v1/echo/<message>', _echoHandler)
  ..post('/api/v1/submit', _submitHandler);

Response _rootHandler(Request req) {
  return Response.ok(
    json.encode({'message': 'Hello, World!'}),
    headers: _headers,
  );
}

Response _notFoundHandler(Request req) {
  return Response.notFound('Request not found "${req.url}" on server');
}

//Response check handler
Response _checkHandler(Request req) {
  return Response.ok(json.encode({'message': 'Welcome to website'}),
      headers: _headers);
}

Response _echoHandler(Request req) {
  final message = req.params['message'];
  return Response.ok('$message\n');
}

Future<Response> _submitHandler(Request req) async {
  try {
    final payload = await req.readAsString();

    final data = json.decode(payload);

    final name = data['name'] as String?;

    if (name != null && name.isNotEmpty) {
      final response = {'message': 'Welcome $name'};

      return Response.ok(
        json.encode(response),
        headers: _headers,
      );
    } else {
      final response = {'message': "Name is null "};

      return Response.badRequest(
        body: json.encode(response),
        headers: _headers,
      );
    }
  } catch (e) {
    final response = {
      'message':
          'Invalid Request!. Please send valid Json data. Error ${e.toString()}'
    };

    return Response.badRequest(
      body: json.encode(req),
      headers: _headers,
    );
  }
}

void main(List<String> args) async {
  final corsHeaders = createMiddleware(requestHandler: (req) {
    if (req.method == 'OPTION') {
      return Response.ok('', headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Method': 'GET, POST, PUT, PATCH, DELETE, HEAD',
        'Access-Control-Allow-Header': 'Content-Type, Authorization',
      });
    }
    return null;
  }, responseHandler: (res) {
    return res.change(headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Method': 'GET, POST, PUT, PATCH, DELETE, HEAD',
      'Access-Control-Allow-Header': 'Content-Type, Authorization',
    });
  });

  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline()
      .addMiddleware(corsHeaders)
      .addMiddleware(logRequests())
      .addHandler(_router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server running on http://${server.address.host}:${server.port}');
}
