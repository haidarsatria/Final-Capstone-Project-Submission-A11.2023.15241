import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'product_form_screen.dart';
import '../../../core/utils/currency_formatter.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _filterMode = "Semua";
  final List<String> _filterOptions = [
    "Semua",
    "Stok Menipis",
    "Makanan",
    "Minuman",
    "Sembako",
    "Alat Tulis",
    "Lainnya"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stok Barang")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ProductFormScreen()));
          if (context.mounted) {
            Provider.of<ProductProvider>(context, listen: false)
                .fetchProducts();
          }
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari nama produk...",
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) {
                Provider.of<ProductProvider>(context, listen: false)
                    .searchProduct(val);
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: _filterOptions.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: _filterMode == filter,
                    selectedColor: Colors.green.shade100,
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() {
                          _filterMode = filter;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                var displayList = provider.items;

                if (_filterMode == "Stok Menipis") {
                  displayList = displayList.where((p) => p.stock <= 5).toList();
                } else if (_filterMode != "Semua") {
                  displayList = displayList
                      .where((p) => p.category == _filterMode)
                      .toList();
                }

                if (displayList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.filter_list_off,
                            size: 50, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text("Tidak ada produk di kategori '$_filterMode'"),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: displayList.length,
                  itemBuilder: (ctx, i) {
                    final product = displayList[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(color: Colors.grey[200]),
                          child: product.photoUrl != null
                              ? Image.file(File(product.photoUrl!),
                                  fit: BoxFit.cover)
                              : const Icon(Icons.image),
                        ),
                        title: Text(product.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            "${product.category} | Stok: ${product.stock} | ${CurrencyFormatter.format(product.price)}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ProductFormScreen(
                                            product: product)));
                                if (context.mounted) {
                                  Provider.of<ProductProvider>(context,
                                          listen: false)
                                      .fetchProducts();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  provider.deleteProduct(product.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
