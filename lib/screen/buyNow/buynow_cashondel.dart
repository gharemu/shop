import 'package:flutter/material.dart';
import 'package:Deals/services/checkoutservice.dart';

class BuyNowCashOnDeliveryPage extends StatefulWidget {
  final String productId;
  final int quantity;

  const BuyNowCashOnDeliveryPage({Key? key, required this.productId, required this.quantity}) : super(key: key);

  @override
  State<BuyNowCashOnDeliveryPage> createState() => _BuyNowCashOnDeliveryPageState();
}

class _BuyNowCashOnDeliveryPageState extends State<BuyNowCashOnDeliveryPage> {
  final CheckoutService _checkoutService = CheckoutService();
  bool isLoading = true;
  String error = '';
  Map<String, dynamic> orderData = {};

  @override
  void initState() {
    super.initState();
    _fetchOrderData();
  }

  Future<void> _fetchOrderData() async {
    try {
      final data = await _checkoutService.getOrderSummary();
      setState(() {
        orderData = data;
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error.isNotEmpty) {
      return Scaffold(body: Center(child: Text(error)));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Now - Cash On Delivery'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Order for Product ID: ${widget.productId} (Qty: ${widget.quantity})'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order confirmed!')),
                );
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('CONFIRM ORDER'),
            ),
          ],
        ),
      ),
    );
  }
}
