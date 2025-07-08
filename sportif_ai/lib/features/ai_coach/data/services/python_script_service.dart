import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sportif_ai/config/api_config.dart';

class PythonScriptService {
  static const MethodChannel _channel = MethodChannel('com.sportifai/python_scripts');
  
  // Method to run Python script via platform channel
  Future<Map<String, dynamic>> runPythonScriptViaChannel(
    String scriptName, 
    Map<String, dynamic> args
  ) async {
    try {
      final result = await _channel.invokeMethod('runPythonScript', {
        'scriptName': scriptName,
        'args': jsonEncode(args),
      });
      
      return jsonDecode(result);
    } on PlatformException catch (e) {
      throw Exception('Failed to run Python script: ${e.message}');
    }
  }
  
  // Alternative method to run Python script via HTTP if platform channels are not set up
  Future<Map<String, dynamic>> runPythonScriptViaHttp(
    String scriptName, 
    Map<String, dynamic> args
  ) async {
    try {
      // This assumes you have a local server running that can execute Python scripts
      // You might need to adjust this based on your actual setup
      final localServerUrl = 'http://localhost:5000/run-script';
      
      final response = await http.post(
        Uri.parse(localServerUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'scriptName': scriptName,
          'args': args,
        }),
      ).timeout(const Duration(minutes: 1));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to run Python script: ${response.body}');
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error running Python script: $e');
    }
  }
  
  // Method to directly execute Python script (for development/testing on desktop)
  Future<Map<String, dynamic>> runPythonScriptDirectly(
    String scriptPath, 
    List<String> args
  ) async {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      throw Exception('Direct script execution only supported on desktop platforms');
    }
    
    try {
      final process = await Process.run('python', [scriptPath, ...args]);
      
      if (process.exitCode != 0) {
        throw Exception('Python script error: ${process.stderr}');
      }
      
      return jsonDecode(process.stdout);
    } catch (e) {
      throw Exception('Error executing Python script: $e');
    }
  }
}