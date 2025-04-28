import 'package:flutter/material.dart';
import 'package:Deals/services/checkoutservice.dart';

class OnlinePaymentPage extends StatefulWidget {
  final List<dynamic>? products;
  final double? subtotal;
  final double? deliveryCharge;
  final double? totalAmount;
  final bool isSingleProductPurchase;

  const OnlinePaymentPage({
    Key? key,
    this.products,
    this.subtotal,
    this.deliveryCharge,
    this.totalAmount,
    this.isSingleProductPurchase = false,
  }) : super(key: key);

  @override
  _OnlinePaymentPageState createState() => _OnlinePaymentPageState();
}

class _OnlinePaymentPageState extends State<OnlinePaymentPage> {
  final CheckoutService _checkoutService = CheckoutService();
  bool isLoading = true;
  String error = '';
  Map<String, dynamic> orderData = {};
  List<dynamic> displayProducts = [];
  double subtotal = 0.0;
  double deliveryCharge = 50.0;
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    // If products are passed directly, use them instead of fetching
    if (widget.products != null && widget.products!.isNotEmpty) {
      // Use passed products (from single product purchase)
      setState(() {
        displayProducts = widget.products!;
        subtotal = widget.subtotal ?? 0.0;
        deliveryCharge = widget.deliveryCharge ?? 50.0;
        totalAmount = widget.totalAmount ?? 0.0;
        isLoading = false;
      });
    } else {
      // Fetch order data as usual
      _fetchOrderData();
    }
  }

  // Same change as CashOnDeliveryPage.dart
  Future<void> _fetchOrderData() async {
    try {
      // Only fetch from API if not a single product purchase
      if (!widget.isSingleProductPurchase) {
        final orderSummary = await _checkoutService.getOrderSummary();
        setState(() {
          orderData = orderSummary;
          displayProducts = orderData['products'] ?? [];
          subtotal =
              double.tryParse(orderData['orderTotal']?.toString() ?? '0.0') ??
              0.0;
          totalAmount = subtotal + deliveryCharge;
          isLoading = false;
        });
      } else {
        // For single product, we already have the data
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading order summary: $e');
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
        title: const Text('Online Payment'),
        backgroundColor: const Color.fromARGB(255, 236, 179, 198),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Confirmed Order Text
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'CONFIRMED ORDER',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
              ),
            ),

            // Product Cards
            _buildProductCards(displayProducts),

            // Price Breakdown
            _buildPriceBreakdown(),

            // Order Details
            _buildOrderDetails('Online Payment'),

            // Delivery Address
            _buildAddressCard(orderData['address'] ?? 'Address not available'),

            // Pay Now Button
            _buildPayNowButton(context),
          ],
        ),
      ),
    );
  }

  // Build the product cards
  Widget _buildProductCards(List products) {
    return Column(
      children:
          products.map<Widget>((product) {
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product image
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          product['image'] != null
                              ? Image.network(
                                product['image'],
                                fit: BoxFit.cover,
                              )
                              : const Icon(
                                Icons.smartphone,
                                size: 50,
                                color: Colors.grey,
                              ),
                    ),
                    const SizedBox(width: 16),
                    // Product details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'] ?? 'Product Name',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
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

  // Build price breakdown section
  Widget _buildPriceBreakdown() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _priceRow('Item Total', '\$${subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _priceRow(
              'Delivery Charge',
              '\$${deliveryCharge.toStringAsFixed(2)}',
            ),
            const Divider(),
            _priceRow(
              'Total',
              '\$${totalAmount.toStringAsFixed(2)}',
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  // Build order details section
  Widget _buildOrderDetails(String paymentMethod) {
    final orderNumber =
        orderData['orderNumber'] ??
        'OD${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final arrivalDate =
        orderData['arrivalDate'] ??
        '${DateTime.now().add(const Duration(days: 5)).day}/${DateTime.now().add(const Duration(days: 5)).month}/${DateTime.now().add(const Duration(days: 5)).year}';

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
            _detailRow('Payment Method:', paymentMethod),
            _detailRow('Estimated Arrival:', arrivalDate),
          ],
        ),
      ),
    );
  }

  // Build address card section
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

  // Pay Now Button
  Widget _buildPayNowButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Redirecting to payment gateway...'),
              backgroundColor: Colors.blue,
            ),
          );
          // Here you would integrate with a payment gateway
          // For demo purposes, we'll just show a dialog
          Future.delayed(const Duration(seconds: 1), () {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Payment Gateway'),
                    content: const Text(
                      'This is where your payment gateway integration would appear.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Pop back to the main screen instead of just the previous screen
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                        child: const Text('Complete Payment'),
                      ),
                    ],
                  ),
            );
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 239, 132, 168),
          foregroundColor: Colors.white,
        ),
        child: const Text(
          'PAY NOW',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Price row for breakdown
  Widget _priceRow(String label, String amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Section title
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  // Detail row for order information
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
