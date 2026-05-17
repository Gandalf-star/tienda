import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';

class AdminProductFormScreen extends StatefulWidget {
  final Product? product;
  const AdminProductFormScreen({super.key, this.product});
  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _sizeCtrl;
  late final TextEditingController _colorCtrl;
  late bool _isAvailable;
  late List<String> _images;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(text: p?.price.toString() ?? '');
    _qtyCtrl = TextEditingController(text: p?.quantity.toString() ?? '');
    _categoryCtrl = TextEditingController(text: p?.category ?? 'General');
    _sizeCtrl = TextEditingController(text: p?.size ?? '');
    _colorCtrl = TextEditingController(text: p?.color ?? '');
    _isAvailable = p?.isAvailable ?? true;
    _images = p != null ? List<String>.from(p.images) : [];
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.gold), onPressed: () => Navigator.pop(context)),
        title: Text(isEditing ? 'Editar Producto' : 'Nuevo Producto',
          style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildField(_nameCtrl, 'Nombre del producto', Icons.label_outline, required: true),
            const SizedBox(height: 14),
            _buildField(_descCtrl, 'Descripción', Icons.description_outlined, maxLines: 3, required: true),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _buildField(_priceCtrl, 'Precio (USD)', Icons.attach_money, isNumber: true, required: true)),
              const SizedBox(width: 12),
              Expanded(child: _buildField(_qtyCtrl, 'Cantidad', Icons.inventory_2_outlined, isNumber: true, required: true)),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _buildField(_categoryCtrl, 'Categoría', Icons.category_outlined)),
              const SizedBox(width: 12),
              Expanded(child: _buildField(_sizeCtrl, 'Tallas (ej: S, M, L)', Icons.straighten)),
            ]),
            const SizedBox(height: 14),
            _buildField(_colorCtrl, 'Colores disponibles (ej: Rojo, Azul)', Icons.color_lens_outlined),
            const SizedBox(height: 14),
            // Availability switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: AppTheme.cardDecoration,
              child: SwitchListTile(
                title: Text('Disponible', style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 15)),
                subtitle: Text(_isAvailable ? 'Visible para clientes' : 'Oculto del catálogo', style: GoogleFonts.poppins(color: AppTheme.textMuted, fontSize: 12)),
                value: _isAvailable,
                onChanged: (v) => setState(() => _isAvailable = v),
                activeColor: AppTheme.gold,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 20),
            // Images section
            Text('Imágenes del producto', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            if (_images.isNotEmpty)
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (_, index) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Stack(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(base64Decode(_images[index]), width: 110, height: 110, fit: BoxFit.cover),
                      ),
                      Positioned(top: 4, right: 4, child: GestureDetector(
                        onTap: () => setState(() => _images.removeAt(index)),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: AppTheme.error, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      )),
                    ]),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text('Agregar imagen', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.gold, side: const BorderSide(color: AppTheme.gold),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(isEditing ? 'Guardar cambios' : 'Crear producto',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon,
      {int maxLines = 1, bool isNumber = false, bool required = false}) {
    return TextFormField(
      controller: ctrl, maxLines: maxLines,
      style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 14),
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: AppTheme.gold, size: 20)),
      validator: required ? (v) {
        if (v == null || v.isEmpty) return 'Requerido';
        if (isNumber && double.tryParse(v) == null) return 'Número inválido';
        return null;
      } : null,
    );
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false, withData: true);
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) setState(() => _images.add(base64Encode(file.bytes!)));
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ProductProvider>();
    final price = double.parse(_priceCtrl.text.trim());
    final qty = int.parse(_qtyCtrl.text.trim());
    if (widget.product != null) {
      provider.updateProduct(widget.product!.copyWith(
        name: _nameCtrl.text.trim(), description: _descCtrl.text.trim(),
        price: price, quantity: qty, isAvailable: _isAvailable, images: _images,
        category: _categoryCtrl.text.trim(), 
        size: _sizeCtrl.text.trim().isEmpty ? null : _sizeCtrl.text.trim(),
        color: _colorCtrl.text.trim().isEmpty ? null : _colorCtrl.text.trim(),
      ));
    } else {
      provider.addProduct(Product(
        id: provider.generateId(), name: _nameCtrl.text.trim(), description: _descCtrl.text.trim(),
        price: price, quantity: qty, isAvailable: _isAvailable, images: _images,
        category: _categoryCtrl.text.trim(), 
        size: _sizeCtrl.text.trim().isEmpty ? null : _sizeCtrl.text.trim(),
        color: _colorCtrl.text.trim().isEmpty ? null : _colorCtrl.text.trim(),
      ));
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose();
    _qtyCtrl.dispose(); _categoryCtrl.dispose(); _sizeCtrl.dispose(); _colorCtrl.dispose();
    super.dispose();
  }
}
