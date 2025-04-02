import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          // Example item in the cart
          CartItem(),
          CartItem(),
          CartItem(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total: \$150', style: TextStyle(fontSize: 18)),
              ElevatedButton(
                onPressed: () {
                  // Navigate to checkout screen
                },
                child: const Text('Checkout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  const CartItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ListTile(
        leading: Icon(Icons.shopping_bag_outlined, color: Colors.green),
        title: const Text('Product Name'),
        subtitle: const Text('Product Description'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Price: \$50'),
            Icon(Icons.delete, color: Colors.red),
          ],
        ),
      ),
    );
  }
}
