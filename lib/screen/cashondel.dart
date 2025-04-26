import 'package:flutter/material.dart';
import 'package:Deals/services/checkoutservice.dart'; // Import the CheckoutService

class CashOnDeliveryPage extends StatefulWidget {
  const CashOnDeliveryPage({Key? key}) : super(key: key);

  @override
  _CashOnDeliveryPageState createState() => _CashOnDeliveryPageState();
}

class _CashOnDeliveryPageState extends State<CashOnDeliveryPage> {
  final CheckoutService _checkoutService = CheckoutService();
  bool isLoading = true;
  String error = '';
  Map<String, dynamic> orderData = {}; // To hold fetched order data

  @override
  void initState() {
    super.initState();
    _fetchOrderData();
  }

  Future<void> _fetchOrderData() async {
    try {
      final orderSummary = await _checkoutService.getOrderSummary(); // Fetch dynamic order data
      setState(() {
        orderData = orderSummary; // Store the fetched order data
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load order summary';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error.isNotEmpty) {
      return Scaffold(
        body: Center(child: Text(error)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash on Delivery'),
        backgroundColor: const Color.fromARGB(255, 236, 179, 198),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCenterTitle('CONFIRMED ORDER', Colors.pinkAccent),
            _buildProductCards(orderData['products'] ?? []),
            _buildPriceBreakdown(orderData),
            _buildOrderDetails(orderData, 'Cash on Delivery'),
            _buildAddressCard(orderData['address'] ?? 'Address not available'),
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

  Widget _buildProductCards(List products) {
    return Column(
      children: products.map<Widget>((product) {
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
                  child: product['image'] != null
                      ? Image.network(product['image'], fit: BoxFit.cover)
                      : const Icon(Icons.smartphone, size: 50, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['name'] ?? 'Product Name',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Price: \$${product['price']}'),
                      Text('Quantity: ${product['quantity']}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceBreakdown(Map<String, dynamic> orderData) {
    double total = double.tryParse(orderData['orderTotal']?.toString() ?? '0.0') ?? 0.0;
    double deliveryCharge = 50.0; // Assuming delivery charge is constant for all orders

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _priceRow('Item Total', '\$${orderData['orderTotal']}'),
            const SizedBox(height: 8),
            _priceRow('Delivery Charge', '\$50.00'),
            const Divider(),
            _priceRow('Total', '\$${total + deliveryCharge}', isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails(Map<String, dynamic> orderData, String paymentMethod) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Order Details'),
            _detailRow('Order Number:', orderData['orderNumber'] ?? 'N/A'),
            _detailRow('Payment Method:', paymentMethod),
            _detailRow('Estimated Arrival:', orderData['arrivalDate'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(String address) {
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
            Text(address),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order confirmed! Thank you for your purchase.'),
              backgroundColor: Colors.green,
            ),
          );
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 239, 132, 168),
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
