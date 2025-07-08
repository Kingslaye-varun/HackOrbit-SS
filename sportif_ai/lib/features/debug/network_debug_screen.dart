import 'package:flutter/material.dart';
import 'package:sportif_ai/config/api_config.dart';
import 'package:sportif_ai/core/utils/network_utils.dart';

class NetworkDebugScreen extends StatefulWidget {
  const NetworkDebugScreen({Key? key}) : super(key: key);

  @override
  State<NetworkDebugScreen> createState() => _NetworkDebugScreenState();
}

class _NetworkDebugScreenState extends State<NetworkDebugScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _diagnosticResults = {};
  String _testEndpointResult = '';

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await NetworkUtils.runNetworkDiagnostic();
      setState(() {
        _diagnosticResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error running diagnostics: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testEndpoint(String endpoint) async {
    setState(() {
      _isLoading = true;
      _testEndpointResult = 'Testing...';
    });

    try {
      // Make sure we're using the correct URL format
      final url = endpoint.startsWith('http') 
          ? endpoint 
          : '${ApiConfig.baseUrl}/$endpoint';
          
      final response = await NetworkUtils.testEndpoint(url);
      setState(() {
        _testEndpointResult = 'Status: ${response.statusCode}\n\nBody: ${response.body}';
      });
    } catch (e) {
      setState(() {
        _testEndpointResult = 'Error: $e';
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
      appBar: AppBar(
        title: const Text('Network Diagnostics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _runDiagnostics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDiagnosticCard(),
                  const SizedBox(height: 16),
                  _buildApiConfigCard(),
                  const SizedBox(height: 16),
                  _buildEndpointTester(),
                  const SizedBox(height: 16),
                  _buildTroubleshootingGuide(),
                ],
              ),
            ),
    );
  }

  Widget _buildDiagnosticCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Network Diagnostic Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildDiagnosticItem(
              'Internet Connection',
              _diagnosticResults['hasInternet'] == true,
            ),
            _buildDiagnosticItem(
              'Backend Reachable',
              _diagnosticResults['backendReachable'] == true,
            ),
            _buildDiagnosticItem(
              'Ping Success',
              _diagnosticResults['pingSuccess'] == true,
            ),
            const Divider(),
            _buildInfoItem('Device IP', _diagnosticResults['deviceIp'] ?? 'Unknown'),
            _buildInfoItem('Server IP', _diagnosticResults['serverIp'] ?? 'Unknown'),
            _buildInfoItem('API URL', _diagnosticResults['apiUrl'] ?? 'Unknown'),
            const Divider(),
            const Text(
              'Ping Output:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black87,
              width: double.infinity,
              child: Text(
                _diagnosticResults['pingOutput'] ?? 'No ping data',
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiConfigCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'API Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoItem('Current Base URL', ApiConfig.baseUrl),
            _buildInfoItem('Local IP URL', ApiConfig.localIpUrl),
            _buildInfoItem('Emulator URL', ApiConfig.emulatorUrl),
            _buildInfoItem('Production URL', ApiConfig.productionUrl),
            const Divider(),
            ElevatedButton(
              onPressed: () {
                // Show dialog to update the local IP URL
                _showUpdateIpDialog();
              },
              child: const Text('Update Local IP Address'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndpointTester() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Endpoint Tester',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _testEndpoint('health'),
                    child: const Text('Test Health Endpoint'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _testEndpoint('users'),
                    child: const Text('Test Users Endpoint'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Result:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black87,
              width: double.infinity,
              child: Text(
                _testEndpointResult.isEmpty ? 'No test run yet' : _testEndpointResult,
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTroubleshootingGuide() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Troubleshooting Guide',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Text(
              '1. Ensure your phone and laptop are on the same WiFi network',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Check that both devices show the same WiFi network name.',
            ),
            SizedBox(height: 8),
            Text(
              '2. Verify the backend server is running',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Check the terminal where you started the server for any errors.',
            ),
            SizedBox(height: 8),
            Text(
              '3. Check firewall settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Ensure your firewall allows incoming connections on port 5000.',
            ),
            SizedBox(height: 8),
            Text(
              '4. Update the Local IP Address',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Use the "Update Local IP Address" button to set the correct IP.',
            ),
            SizedBox(height: 8),
            Text(
              '5. Try using ngrok',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'If direct connection fails, consider using ngrok to expose your local server.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticItem(String label, bool isSuccess) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Text(
            isSuccess ? 'Success' : 'Failed',
            style: TextStyle(
              color: isSuccess ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showUpdateIpDialog() {
    final TextEditingController controller = TextEditingController(
      text: ApiConfig.localIpUrl.replaceAll('http://', '').replaceAll(':5000/api', ''),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Local IP Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your laptop\'s IP address (without http:// or port)',
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'e.g. 192.168.1.5',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newIp = controller.text.trim();
              if (newIp.isNotEmpty) {
                // Update the IP and reconnect
                ApiConfig.setBaseUrl('http://$newIp:5000/api');
                Navigator.pop(context);
                _runDiagnostics();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}