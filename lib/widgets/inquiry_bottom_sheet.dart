import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../services/whatsapp_service.dart';
import '../theme/app_theme.dart';

class InquiryBottomSheet extends StatefulWidget {
  final Product product;

  const InquiryBottomSheet({super.key, required this.product});

  static void show(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InquiryBottomSheet(product: product),
    );
  }

  @override
  State<InquiryBottomSheet> createState() => _InquiryBottomSheetState();
}

class _InquiryBottomSheetState extends State<InquiryBottomSheet> {
  final _messageCtrl = TextEditingController();
  final List<String> _quickQuestions = [
    '¿Está disponible en otro color?',
    '¿Cuál es el material?',
    '¿Tienen envío a domicilio?',
    '¿Aceptan pagos con tarjeta?',
    '¿Cuánto tarda el envío?',
  ];

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.chat_bubble_outline, color: AppTheme.gold, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consultar producto',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.product.name,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Quick questions
              Text(
                'Preguntas frecuentes',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickQuestions.map((q) {
                  final isSelected = _messageCtrl.text == q;
                  return GestureDetector(
                    onTap: () => setState(() => _messageCtrl.text = q),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.gold.withValues(alpha: 0.15)
                            : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppTheme.gold : AppTheme.surfaceBorder,
                        ),
                      ),
                      child: Text(
                        q,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isSelected ? AppTheme.gold : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Custom message field
              TextField(
                controller: _messageCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Escribe tu pregunta aquí...',
                  hintStyle: GoogleFonts.poppins(color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppTheme.surfaceBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppTheme.surfaceBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.gold),
                  ),
                ),
                style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 14),
              ),

              const SizedBox(height: 20),

              // Send button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _sendInquiry,
                  icon: const Icon(Icons.send_rounded, size: 20),
                  label: Text(
                    'Enviar por WhatsApp',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.whatsapp,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendInquiry() async {
    if (_messageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe una pregunta primero')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final number = auth.whatsappNumber;
    if (number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay número de WhatsApp configurado')),
      );
      return;
    }
    await WhatsAppService.sendInquiry(number, widget.product, _messageCtrl.text.trim());
    if (mounted) Navigator.pop(context);
  }
}
