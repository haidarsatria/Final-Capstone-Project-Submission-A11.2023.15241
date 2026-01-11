import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warungku/features/sales/screens/payment_screen.dart';
import '../../products/providers/product_provider.dart';
import '../providers/cart_provider.dart';
import 'scan_screen.dart';
import '/features/inventory_analytics/screens/settings_screen.dart';
import '../../../core/utils/currency_formatter.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  String _searchQuery = "";
  String _selectedCategory = "Semua";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    Set<String> categories = {"Semua"};
    for (var item in productProvider.items) {
      if (item.category.isNotEmpty) {
        categories.add(item.category);
      }
    }

    // 2. Filter List Produk
    final filteredProducts = productProvider.items.where((product) {
      // Filter Nama
      final matchName =
          product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      // Filter Kategori
      final matchCategory =
          _selectedCategory == "Semua" || product.category == _selectedCategory;

      return matchName && matchCategory;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],

      // APP BAR
      appBar: AppBar(
        title: const Text("Kasir WarungKu"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Data",
            onPressed: () => productProvider.fetchProducts(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Pengaturan Struk",
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Cari nama barang...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = "";
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: Colors.green.shade100,
                          labelStyle: TextStyle(
                            color:
                                isSelected ? Colors.green[800] : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        Text("Produk tidak ditemukan",
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.70,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (ctx, i) {
                      final product = filteredProducts[i];
                      final isOutOfStock = product.stock <= 0;

                      return Card(
                        elevation: 3,
                        shadowColor: Colors.black26,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () {
                            if (isOutOfStock) {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Stok barang ini habis!"),
                                backgroundColor: Colors.red,
                                duration: Duration(milliseconds: 800),
                                behavior: SnackBarBehavior.floating,
                              ));
                              return;
                            }

                            String? errorMsg = cartProvider.addToCart(product);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();

                            if (errorMsg == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${product.name} +1"),
                                  duration: const Duration(milliseconds: 500),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMsg),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Foto
                              Expanded(
                                flex: 3,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    product.photoUrl != null
                                        ? Image.file(
                                            File(product.photoUrl!),
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                        Icons.broken_image)),
                                          )
                                        : Container(
                                            color: Colors.green.shade50,
                                            child: Icon(Icons.storefront,
                                                size: 40,
                                                color: Colors.green.shade200),
                                          ),
                                    if (isOutOfStock)
                                      Container(
                                        color: Colors.black.withOpacity(0.6),
                                        child: const Center(
                                          child: Text("HABIS",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Info
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        product.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              CurrencyFormatter.format(
                                                  product.price),
                                              style: const TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                            isOutOfStock
                                                ? "Stok: 0"
                                                : "Sisa: ${product.stock}",
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: isOutOfStock
                                                    ? Colors.red
                                                    : Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // TOMBOL SCAN
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ScanScreen()));
        },
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.qr_code_scanner, size: 30),
      ),

      // PANEL BAWAH
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 10,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total (${cartProvider.items.length} Item)",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      CurrencyFormatter.format(cartProvider.totalAmount),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 60),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: cartProvider.items.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PaymentScreen()));
                      },
                child: const Row(
                  children: [
                    Text("BAYAR",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 5),
                    Icon(Icons.chevron_right, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
