import 'package:flutter/material.dart';
import 'package:Deals/services/checkoutservice.dart';

class CashOnDeliveryPage extends StatefulWidget {
  final List<dynamic>? products;
  final double? subtotal;
  final double? deliveryCharge;
  final double? totalAmount;
  final bool isSingleProductPurchase;

  const CashOnDeliveryPage({
    Key? key,
    this.products,
    this.subtotal,
    this.deliveryCharge,
    this.totalAmount,
    this.isSingleProductPurchase = false,
  }) : super(key: key);

  @override
  _CashOnDeliveryPageState createState() => _CashOnDeliveryPageState();
}

class _CashOnDeliveryPageState extends State<CashOnDeliveryPage> {
  final CheckoutService _checkoutService = CheckoutService();
  bool isLoading = true;
  String error = '';
  Map<String, dynamic> orderData = {};
  List<dynamic> displayProducts = [];
  double subtotal = 0.0;
  double deliveryCharge = 0.0;
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();

    // If products are passed directly, use them
    if (widget.products != null && widget.products!.isNotEmpty) {
      setState(() {
        displayProducts = widget.products!;
        subtotal = widget.subtotal ?? 0.0;
        deliveryCharge = widget.deliveryCharge ?? 50.0;
        totalAmount = widget.totalAmount ?? 0.0;
        isLoading = false;
      });
    } else {
      // Fetch order data from API
      _fetchOrderData();
    }
  }

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
        title: const Text('Cash on Delivery'),
        backgroundColor: const Color.fromARGB(255, 236, 179, 198),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCenterTitle('CONFIRMED ORDER', Colors.pinkAccent),
            _buildProductCards(displayProducts),
            _buildPriceBreakdown(),
            _buildOrderDetails('Cash on Delivery'),
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
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCards(List products) {
    return Column(
      children:
          products.map<Widget>((product) {
            // Handle both API objects and passed products
            final name = product['name'] ?? product['title'] ?? 'Product Name';
            final price =
                product['price'] ?? product['discount_price'] ?? '0.0';
            final quantity = product['quantity'] ?? 1;
            final image = product['image'] ?? product['imageUrl'];

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
                      child:
                          image != null
                              ? Image.network(image, fit: BoxFit.cover)
                              : const Icon(
                                Icons.smartphone,
                                size: 50,
                                color: Colors.grey,
                              ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Price: \$${price}'),
                          Text('Quantity: ${quantity}'),
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
            // Pop back to the main screen instead of just the previous screen
            Navigator.of(context).popUntil((route) => route.isFirst);
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 239, 132, 168),
          foregroundColor: Colors.white,
        ),
        child: const Text(
          'CONFIRM ORDER',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

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

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

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
