import 'package:flutter/material.dart';
import 'package:Deals/services/checkoutservice.dart'; // Updated to match the import in BuyNowCheckoutPage

class OnlinePaymentPage extends StatefulWidget {
  final dynamic product; // Accept the full product object
  final int quantity;
  final String address;
  final String name;
  final String phoneNumber;
  final double deliveryCharge;
  final double totalAmount;

  const OnlinePaymentPage({
    Key? key, 
    required this.product, 
    required this.quantity,
    required this.address,
    required this.name,
    required this.phoneNumber,
    required this.deliveryCharge,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<OnlinePaymentPage> createState() => _BuyNowCashOnDeliveryPageState();
}

class _BuyNowCashOnDeliveryPageState extends State<OnlinePaymentPage> {
  final CheckoutService _checkoutService = CheckoutService();
  bool isLoading = false;
  String error = '';
  late String orderNumber;

  @override
  void initState() {
    super.initState();
    // Generate a random order number
    orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF3E6C))),
      );
    }

    if (error.isNotEmpty) {
      return Scaffold(
        body: Center(child: Text(error)),
      );
    }

    // Calculate price values
    final productPrice = double.tryParse(widget.product.discountPrice ?? '0.0') ?? 0.0;
    final subtotal = productPrice * widget.quantity;
    final total = subtotal + widget.deliveryCharge;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Now - Cash On Delivery'),
        backgroundColor: const Color(0xFFFF3E6C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCenterTitle('CONFIRMED ORDER', Colors.pinkAccent),
            _buildProductCard(widget.product, widget.quantity),
            _buildPriceBreakdown(subtotal, widget.deliveryCharge, total),
            _buildOrderDetails(orderNumber),
            _buildAddressCard(widget.name, widget.address, widget.phoneNumber),
            _buildConfirmButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterTitle(String text, Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          text,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }

  Widget _buildProductCard(dynamic product, int quantity) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: product.image != null
                  ? Image.network(product.image, fit: BoxFit.cover)
                  : const Icon(Icons.shopping_bag, size: 50, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? 'Product Name',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                  const SizedBox(height: 8),
                  Text('Price: ₹${product.discountPrice}'),
                  Text('Quantity: $quantity'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown(double subtotal, double deliveryCharge, double total) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _priceRow('Item Total', '₹${subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _priceRow('Delivery Charge', '₹${deliveryCharge.toStringAsFixed(2)}'),
            const Divider(),
            _priceRow('Total', '₹${total.toStringAsFixed(2)}', isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails(String orderNumber) {
    // Calculate estimated arrival date (current date + 7 days)
    final today = DateTime.now();
    final arrivalDate = today.add(const Duration(days: 7));
    final formattedDate = '${arrivalDate.day}/${arrivalDate.month}/${arrivalDate.year}';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Order Details'),
            _detailRow('Order Number:', orderNumber),
            _detailRow('Payment Method:', 'Cash on Delivery'),
            _detailRow('Estimated Arrival:', formattedDate),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(String name, String address, String phoneNumber) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Delivery Address'),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(address),
            const SizedBox(height: 4),
            Text(phoneNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // Here you could add logic to save the order to the database
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order confirmed! Thank you for your purchase.'),
              backgroundColor: Colors.green,
            ),
          );
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF3E6C),
          foregroundColor: Colors.white,
        ),
        child: const Text('CONFIRM ORDER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _priceRow(String label, String amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(amount, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}