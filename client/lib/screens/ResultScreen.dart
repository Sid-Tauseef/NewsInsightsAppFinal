import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:client/constants/config.dart';

class ResultScreen extends StatefulWidget {
  final String scanText;

  const ResultScreen({super.key, required this.scanText});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String? summaryText;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Optionally auto-summarize on load by uncommenting:
    // sendDesc(widget.scanText);
  }

  Future<void> sendDesc(String desc) async {
    setState(() {
      isLoading = true;
    });

    try {
      String text = desc.replaceAll(RegExp(r'[\n"]'), '');
      final body = jsonEncode({'text': text});
      final uri = Uri.parse(Config.summarize);
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          summaryText = data['result']['summary_text'];
        });
      } else {
        throw Exception('Failed to summarize: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error summarizing text',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            margin: EdgeInsets.all(10),
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan Result',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 8,
        shadowColor: Colors.black45,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueGrey.shade50,
              Colors.blueAccent.shade100,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Extracted Text',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: Colors.white, // Changed background color to white
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      widget.scanText.isEmpty ? 'No text detected' : widget.scanText,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blueAccent,
                      strokeWidth: 6,
                    ),
                  )
                else if (summaryText != null) ...[
                  const Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: Colors.white, // Also changed summary card to white for consistency
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        summaryText!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      label: 'Copy',
                      icon: Icons.copy,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: widget.scanText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Copied to clipboard',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                            margin: EdgeInsets.all(10),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    _buildActionButton(
                      label: 'Summarize',
                      icon: Icons.summarize,
                      onPressed: isLoading ? null : () => sendDesc(widget.scanText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ButtonStyle(
        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        elevation: MaterialStateProperty.all(6),
        shadowColor: MaterialStateProperty.all(Colors.black45),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey;
            }
            return Colors.blue;
          },
        ),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        overlayColor: MaterialStateProperty.all(Colors.blueAccent.withOpacity(0.2)),
        surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
      ),
    );
  }
}

class SummaryScreen extends StatelessWidget {
  final String summaryText;

  const SummaryScreen({super.key, required this.summaryText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Summary:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(summaryText),
            ],
          ),
        ),
      ),
    );
  }
}