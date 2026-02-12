import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/security/app_security_service.dart';
import '../../../../core/config/theme_config.dart';

/// Security settings screen
class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends ConsumerState<SecuritySettingsScreen> {
  final AppSecurityService _securityService = AppSecurityService();
  
  bool _mpinEnabled = false;
  bool _biometricEnabled = false;
  bool _autoLockEnabled = false;
  bool _canUseBiometric = false;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final mpinEnabled = await _securityService.isMpinEnabled();
    final biometricEnabled = await _securityService.isBiometricEnabled();
    final autoLockEnabled = await _securityService.isAutoLockEnabled();
    final canUseBiometric = await _securityService.canCheckBiometrics();
    
    setState(() {
      _mpinEnabled = mpinEnabled;
      _biometricEnabled = biometricEnabled;
      _autoLockEnabled = autoLockEnabled;
      _canUseBiometric = canUseBiometric;
      _isLoading = false;
    });
  }
  
  Future<void> _setupMpin() async {
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set MPIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Enter 4-6 digit PIN',
                hintText: 'Enter PIN',
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              decoration: const InputDecoration(
                labelText: 'Confirm PIN',
                hintText: 'Re-enter PIN',
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.length < 4 || controller.text.length > 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN must be 4-6 digits')),
                );
                return;
              }
              
              if (controller.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PINs do not match')),
                );
                return;
              }
              
              await _securityService.setMpin(controller.text);
              Navigator.pop(context, true);
            },
            child: const Text('Set PIN'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      setState(() {
        _mpinEnabled = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('MPIN set successfully')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Security Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
      ),
      body: ListView(
        children: [
          // MPIN Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'App Lock',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          
          SwitchListTile(
            title: const Text('Enable MPIN'),
            subtitle: const Text('Secure your app with a 4-6 digit PIN'),
            value: _mpinEnabled,
            onChanged: (value) async {
              if (value) {
                await _setupMpin();
              } else {
                await _securityService.removeMpin();
                setState(() {
                  _mpinEnabled = false;
                });
              }
            },
          ),
          
          if (_canUseBiometric)
            SwitchListTile(
              title: const Text('Enable Biometric Authentication'),
              subtitle: const Text('Use fingerprint or face recognition'),
              value: _biometricEnabled,
              onChanged: (value) async {
                await _securityService.setBiometricEnabled(value);
                setState(() {
                  _biometricEnabled = value;
                });
              },
            ),
          
          SwitchListTile(
            title: const Text('Auto Lock'),
            subtitle: const Text('Lock app when it goes to background'),
            value: _autoLockEnabled,
            onChanged: (value) async {
              await _securityService.setAutoLockEnabled(value);
              setState(() {
                _autoLockEnabled = value;
              });
            },
          ),
          
          if (_mpinEnabled)
            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: const Text('Change MPIN'),
              onTap: _setupMpin,
            ),
          
          const Divider(),
          
          // Encryption Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Encryption',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.enhanced_encryption),
            title: const Text('End-to-End Encryption'),
            subtitle: const Text('All messages are encrypted by default'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ThemeConfig.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Enabled',
                style: TextStyle(
                  color: ThemeConfig.successColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          const Divider(),
          
          // Information
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Security Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• MPIN is stored securely using platform-specific encryption\n'
                  '• Biometric data is managed by your device and never shared\n'
                  '• Messages are encrypted end-to-end using AES-256\n'
                  '• Only you and your contacts can read your messages',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
