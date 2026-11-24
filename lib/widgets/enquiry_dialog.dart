import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/product.dart';
import '../providers/catalog_provider.dart';
import '../services/launcher_helper.dart';
import '../theme/app_theme.dart';

/// Modal dialog for capturing customer Name and Phone Number when
/// placing an agricultural tool enquiry, followed by a confirmed
/// success message and WhatsApp notification dispatch.
class EnquiryDialog extends StatefulWidget {
  final CatalogProvider provider;
  final Product? singleProduct;

  const EnquiryDialog({
    super.key,
    required this.provider,
    this.singleProduct,
  });

  /// Presents the customer enquiry dialog and shows a success confirmation upon completion.
  static Future<void> show(
    BuildContext context, {
    required CatalogProvider provider,
    Product? singleProduct,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => EnquiryDialog(
        provider: provider,
        singleProduct: singleProduct,
      ),
    );
  }

  @override
  State<EnquiryDialog> createState() => _EnquiryDialogState();
}

class _EnquiryDialogState extends State<EnquiryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  String _submittedName = '';
  String _submittedPhone = '';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitEnquiry() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final notes = _notesController.text.trim();

    String enquiryMsg;
    String itemsSummary;
    double totalAmt;

    if (widget.singleProduct != null) {
      final p = widget.singleProduct!;
      itemsSummary = '${p.name} (${p.formattedPrice})';
      totalAmt = p.price;
      enquiryMsg = widget.provider.generateSingleProductEnquiry(
        product: p,
        userName: name,
        userPhone: phone,
        notes: notes,
      );
    } else {
      itemsSummary = widget.provider.cart
          .map((item) => '${item.product.name} x ${item.quantity}')
          .join(', ');
      totalAmt = widget.provider.cartTotal;
      enquiryMsg = widget.provider.generateEnquiryMessage(
        userName: name,
        userPhone: phone,
        notes: notes,
      );
      // Reset cart after enquiry has been placed
      widget.provider.clearCart();
    }

    // Save record to provider
    widget.provider.recordEnquiry(
      name: name,
      phone: phone,
      notes: notes,
      itemsSummary: itemsSummary,
      totalAmount: totalAmt,
    );

    // Transition immediately to Success confirmation view
    setState(() {
      _isSubmitting = false;
      _isSubmitted = true;
      _submittedName = name;
      _submittedPhone = phone;
    });

    // Copy to clipboard as reliable fallback & launch WhatsApp intent in background
    try {
      Clipboard.setData(ClipboardData(text: enquiryMsg));
    } catch (_) {}

    try {
      LauncherHelper.openWhatsApp(enquiryMsg);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // -------------------------------------------------------------
    // SUCCESS VIEW: Shown once enquiry is placed successfully
    // -------------------------------------------------------------
    if (_isSubmitted) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Green check celebration avatar
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.inStockBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.inStockText.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.inStockText,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your enquiry placed successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16.5,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'चौकशी यशस्वीपणे नोंदवली गेली आहे.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.green,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.featureBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: AppColors.green),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'ग्राहक नाव: $_submittedName',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: AppColors.green),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'मोबाईल: $_submittedPhone',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'वाक्षे ॲग्रोटेक टीम (87 88 34 18 95) तुमच्या दिलेल्या नंबरवर संपर्क करेल.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.muted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'ठीक आहे (Done)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // -------------------------------------------------------------
    // INPUT FORM VIEW: Collect customer name, phone, and optional note
    // -------------------------------------------------------------
    final isSingle = widget.singleProduct != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.lime,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: AppColors.green,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'चौकशी नोंदवा (Place Enquiry)',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                Text(
                  'नाव व मोबाईल प्रविष्ट करा',
                  style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary box
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.featureBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    const Text('🌾', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isSingle
                            ? '${widget.singleProduct!.name} · ${widget.singleProduct!.formattedPrice}'
                            : '${widget.provider.cartCount} अवजारे · एकूण: ${widget.provider.formattedCartTotal}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // Name Field
              const Text(
                'तुमचे पूर्ण नाव (Full Name) *',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'उदा. रमेश पाटील',
                  hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.muted),
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    size: 18,
                    color: AppColors.green,
                  ),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide:
                        const BorderSide(color: AppColors.green, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'कृपया तुमचे नाव लिहा (Please enter name)';
                  }
                  if (val.trim().length < 2) {
                    return 'नाव किमान 2 अक्षरी असावे';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Phone Field
              const Text(
                'मोबाईल नंबर (Phone Number) *',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  hintText: '10 अंकी मोबाईल नंबर (e.g. 9876543210)',
                  hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.muted),
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    size: 18,
                    color: AppColors.green,
                  ),
                  prefixText: '+91 ',
                  prefixStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide:
                        const BorderSide(color: AppColors.green, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'कृपया मोबाईल नंबर प्रविष्ट करा';
                  }
                  final clean = val.replaceAll(RegExp(r'\D'), '');
                  if (clean.length != 10) {
                    return 'कृपया अचूक 10 अंकी मोबाईल नंबर टाका';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Optional Notes / Village
              const Text(
                'गाव किंवा संदेश (Village / Note - Optional)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'उदा. वाक्षेवाडी, सांगली (कधी हवी आहे ते नमूद करा)',
                  hintStyle: const TextStyle(fontSize: 12, color: AppColors.muted),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 22),
                    child: Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: AppColors.green,
                    ),
                  ),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide:
                        const BorderSide(color: AppColors.green, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('रद्द करा (Cancel)'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          ),
          icon: const Icon(Icons.send_rounded, size: 16),
          label: const Text(
            'चौकशी पाठवा (Submit)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: _isSubmitting ? null : _submitEnquiry,
        ),
      ],
    );
  }
}
