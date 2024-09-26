import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Flutter Application',
      home: MyHomePage(),
      // home: Scaffold(
      //   body: Center(
      //     child: Text('Hi'),
      //   ),
      // ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = TextEditingController();

  String responseMessage = '';

  Future<void> sendName() async {
    final name = controller.text;

    controller.clear();

    final url = Uri.parse('http://127.0.0.1:8080/api/v1/submit');
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'name': name}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.body.isNotEmpty) {
        final data = json.decode(response.body);

        setState(() {
          responseMessage = data['message'];
        });
      } else {
        setState(() {
          responseMessage = 'Invalid request from server';
        });
      }
    } catch (e) {
      setState(() {
        responseMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Flutter Application')),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: sendName,
              child: const Text('Send'),
            ),
            Text(
              responseMessage,
              style: Theme.of(context).textTheme.titleLarge,
            )
          ],
        ),
      ),
    );
  }
}
