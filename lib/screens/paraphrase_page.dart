import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ParaphrasePage extends StatefulWidget {
  const ParaphrasePage({super.key});

  @override
  State<ParaphrasePage> createState() => _ParaphrasePageState();
}

class _ParaphrasePageState extends State<ParaphrasePage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  bool _isLoading = false;

  Future<void> makePostRequest(String text) async {
    final url =
        Uri.parse('https://paraphrase-genius.p.rapidapi.com/dev/paraphrase/');
    final headers = {
      'X-Rapidapi-Key': 'e782c3adc1msh044c312802562a8p1a5e11jsn85faffc9ff0d',
      'X-Rapidapi-Host': 'paraphrase-genius.p.rapidapi.com',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({'text': text, 'result_type': 'single'});

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _outputController.text = responseData[
              'paraphrased_text']; // Adjust based on actual response structure
        });
      } else {
        setState(() {
          _outputController.text =
              'Request failed with status: ${response.statusCode}';
          setState(() {
            _isLoading = false;
          });
        });
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _outputController.text = 'Request failed with error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Paraphrase Text')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                textInputAction: TextInputAction.done,
                controller: _inputController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter text to paraphrase',
                ),
                maxLines: null,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        final text = _inputController.text;
                        if (text.isNotEmpty) {
                          makePostRequest(text);
                        }
                      },
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Paraphrase'),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _outputController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Paraphrased text',
                ),
                maxLines: null,
                readOnly: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
