import 'package:flutter/material.dart';
import '../providers/catalog_provider.dart';
import '../theme/app_theme.dart';

/// Modal dialog prompting for administrator authentication credentials
class AdminLoginDialog extends StatefulWidget {
  final CatalogProvider provider;

  const AdminLoginDialog({super.key, required this.provider});

  static Future<bool?> show(BuildContext context, CatalogProvider provider) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AdminLoginDialog(provider: provider),
    );
  }

  @override
  State<AdminLoginDialog> createState() => _AdminLoginDialogState();
}

class _AdminLoginDialogState extends State<AdminLoginDialog> {
  final TextEditingController _passcodeController = TextEditingController();
  bool _obscureText = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passcodeController.dispose();
    super.dispose();
  }

  void _submit() {
    final passcode = _passcodeController.text.trim();
    if (passcode.isEmpty) {
      setState(() => _errorMessage = 'Please enter administrator passcode');
      return;
    }

    final success = widget.provider.authenticateAdmin(passcode);
    if (success) {
      Navigator.of(context).pop(true);
      widget.provider.showAdminView();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.green,
          content: Text('Admin access granted. Welcome to Wakshe Agrotech dashboard.'),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Invalid passcode. (Demo default: admin123)';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Row(
        children: [
          Icon(Icons.admin_panel_settings, color: AppColors.green, size: 28),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Administrator Access',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your administrator passcode to manage products, pricing, and stock inventory.',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passcodeController,
              obscureText: _obscureText,
              autofocus: true,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Admin Passcode',
                hintText: 'admin123',
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
                errorText: _errorMessage,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Default demo passcode: admin123',
              style: TextStyle(fontSize: 11, color: AppColors.muted, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _submit,
          child: const Text('Unlock Dashboard'),
        ),
      ],
    );
  }
}
