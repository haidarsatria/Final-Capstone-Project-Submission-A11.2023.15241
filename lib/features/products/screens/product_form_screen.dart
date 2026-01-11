import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../widgets/barcode_scanner_view.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _barcodeController;

  String _selectedCategory = "Makanan";
  final List<String> _categories = [
    "Makanan",
    "Minuman",
    "Sembako",
    "Alat Tulis",
    "Lainnya"
  ];

  String? _imagePath;

  @override
  void initState() {
    super.initState();
    // Pre-fill data jika mode EDIT
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController =
        TextEditingController(text: widget.product?.stock.toString() ?? '');
    _barcodeController =
        TextEditingController(text: widget.product?.barcode ?? '');

    _imagePath = widget.product?.photoUrl;

    // Load Category Logic
    if (widget.product != null) {
      if (_categories.contains(widget.product!.category)) {
        _selectedCategory = widget.product!.category;
      } else {
        _selectedCategory = "Lainnya";
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _imagePath = pickedFile.path);
    }
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final newProduct = Product(
        id: widget.product?.id,
        name: _nameController.text,
        price: int.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        category: _selectedCategory,
        photoUrl: _imagePath,
        barcode: _barcodeController.text.isEmpty
            ? 'BC-${DateTime.now().millisecondsSinceEpoch}'
            : _barcodeController.text,
      );

      final provider = Provider.of<ProductProvider>(context, listen: false);

      if (widget.product != null) {
        provider.updateProduct(newProduct);
      } else {
        provider.addProduct(newProduct);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(widget.product != null ? "Edit Produk" : "Tambah Produk")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- FOTO PRODUK ---
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imagePath != null
                      ? Image.file(File(_imagePath!), fit: BoxFit.cover)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Icon(Icons.camera_alt, size: 40),
                              Text("Tap ganti foto")
                            ]),
                ),
              ),
              const SizedBox(height: 20),

              // --- INPUT BARCODE ---
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(
                          labelText: "Barcode ID (Scan/Ketik)",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.qr_code)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Tombol Buka Kamera Scanner
                  Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(5)),
                    child: IconButton(
                      icon: const Icon(Icons.qr_code_scanner,
                          color: Colors.white),
                      onPressed: () async {
                        final code = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const BarcodeScannerView()));
                        if (code != null) {
                          setState(() {
                            _barcodeController.text = code;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Barcode Terdeteksi: $code")));
                        }
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),

              // --- NAMA PRODUK ---
              TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: "Nama Produk", border: OutlineInputBorder())),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                    labelText: "Kategori", border: OutlineInputBorder()),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              const SizedBox(height: 10),

              // --- HARGA & STOK ---
              Row(children: [
                Expanded(
                    child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: "Harga", border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(
                    child: TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: "Stok", border: OutlineInputBorder()))),
              ]),
              const SizedBox(height: 20),

              // --- TOMBOL SIMPAN ---
              SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white),
                      child: const Text("SIMPAN")))
            ],
          ),
        ),
      ),
    );
  }
}
