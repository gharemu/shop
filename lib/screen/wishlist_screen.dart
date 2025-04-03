import 'package:flutter/material.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<String> wishlist = []; // List to store wishlist items

  void addToWishlist(String product) {
    setState(() {
      wishlist.add(product);
    });
  }

  void removeFromWishlist(int index) {
    setState(() {
      wishlist.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body:
          wishlist.isEmpty
              ? const Center(child: Text('No items in wishlist'))
              : ListView.builder(
                itemCount: wishlist.length,
                itemBuilder: (context, index) {
                  return WishlistItem(
                    productName: wishlist[index],
                    onDelete: () => removeFromWishlist(index),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addToWishlist('Product ${wishlist.length + 1}'); // Dummy product
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class WishlistItem extends StatelessWidget {
  final String productName;
  final VoidCallback onDelete;

  const WishlistItem({
    super.key,
    required this.productName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ListTile(
        leading: const Icon(Icons.favorite, color: Colors.red),
        title: Text(productName),
        subtitle: const Text('Product Description'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
