import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _footerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('shop_name') ?? 'WarungKu POS';
      _addressController.text =
          prefs.getString('shop_address') ?? 'Jalan Raya No. 1';
      _phoneController.text = prefs.getString('shop_phone') ?? '0812-3456-7890';
      _footerController.text =
          prefs.getString('shop_footer') ?? 'Terima Kasih & Datang Lagi';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shop_name', _nameController.text);
    await prefs.setString('shop_address', _addressController.text);
    await prefs.setString('shop_phone', _phoneController.text);
    await prefs.setString('shop_footer', _footerController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Pengaturan Struk Disimpan!"),
            backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan Struk")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Info Toko (Akan muncul di Struk)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
                labelText: "Nama Toko",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
                labelText: "Alamat Toko",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
                labelText: "Nomor Telepon",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone)),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _footerController,
            decoration: const InputDecoration(
                labelText: "Pesan Bawah (Footer)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
                hintText: "Contoh: Barang tidak dapat ditukar"),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save),
              label: const Text("SIMPAN PENGATURAN"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
