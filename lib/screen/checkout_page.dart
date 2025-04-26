import 'package:Deals/screen/cashondel.dart';
import 'package:Deals/screen/onlinepayment.dart';
import 'package:flutter/material.dart';
import 'package:Deals/services/checkoutservice.dart';
import 'package:Deals/login/profile_account.dart';

class CheckoutPage extends StatefulWidget {
  final List<dynamic>? products;
  final Map<String, int>? quantities;
  final bool comingFromProfile;

  const CheckoutPage({
    Key? key,
    this.products,
    this.quantities,
    this.comingFromProfile = false,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String name = '';
  String address = '';
  String phoneNumber = '';
  String paymentMethod = 'cash-on-delivery';
  final CheckoutService _checkoutService = CheckoutService();
  bool isLoading = true;
  String error = '';
  double subtotal = 0.0;
  double deliveryCharge = 40.0;
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    loadCheckoutData();

    // Show welcome back message if coming from profile
    if (widget.comingFromProfile) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address updated successfully!'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }

  Future<void> loadCheckoutData() async {
    try {
      final data = await _checkoutService.getCheckout();

      setState(() {
        // Check if address is a Map or convert as needed
        if (data['address'] is Map) {
          Map<String, dynamic> addressData = data['address'];
          name = addressData['name']?.toString() ?? '';
          address = addressData['address']?.toString() ?? '';
          phoneNumber = addressData['phone_number']?.toString() ?? '';
        } else {
          // Alternative approach if the structure is different
          name = data['name']?.toString() ?? '';
          address = data['address']?.toString() ?? '';
          phoneNumber = data['phone_number']?.toString() ?? '';
        }

        // Calculate order total if products are passed
        if (widget.products != null && widget.quantities != null) {
          calculateTotal();
        } else if (data['cart_items'] != null && data['cart_items'] is List) {
          // Calculate based on cart items from API
          calculateTotalFromApi(data['cart_items']);
        }

        isLoading = false;
      });
    } catch (e) {
      print('Error loading checkout data: $e');
      setState(() {
        error = 'Failed to load checkout details. Please try again.';
        isLoading = false;
      });
    }
  }

  void calculateTotal() {
    double sum = 0.0;
    if (widget.products != null && widget.quantities != null) {
      for (var product in widget.products!) {
        final productId = product.id.toString();
        final quantity = widget.quantities![productId] ?? 1;
        final price = double.tryParse(product.discountPrice ?? '0.0') ?? 0.0;
        sum += price * quantity;
      }
    }

    setState(() {
      subtotal = sum;
      totalAmount = subtotal + deliveryCharge;
    });
  }

  void calculateTotalFromApi(List<dynamic> cartItems) {
    double sum = 0.0;
    for (var item in cartItems) {
      final quantity = item['quantity'] ?? 1;
      final price =
          double.tryParse(item['discount_price']?.toString() ?? '0.0') ?? 0.0;
      sum += price * quantity;
    }

    setState(() {
      subtotal = sum;
      totalAmount = subtotal + deliveryCharge;
    });
  }

  void onContinue() {
    if (name.isEmpty || address.isEmpty || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete your delivery details'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (paymentMethod == 'cash-on-delivery') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CashOnDeliveryPage()),
      );
    } else if (paymentMethod == 'online') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OnlinePaymentPage()),
      );
    }
  }

  void gotoProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    ).then((_) {
      // Reload checkout data when returning from profile
      setState(() {
        isLoading = true;
      });
      loadCheckoutData();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF3E6C)),
        ),
      );
    }

    if (error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                error,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    error = '';
                    isLoading = true;
                  });
                  loadCheckoutData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          // Shopping bag summary
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: const Color(0xFFECF3F9),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag, color: Color(0xFF3D7BE2)),
                const SizedBox(width: 12),
                Text(
                  'Your order is just a few steps away',
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Delivery address section with improved design
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFFFF3E6C),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'DELIVERY ADDRESS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: gotoProfile,
                        icon: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Color(0xFFFF3E6C),
                        ),
                        label: const Text(
                          'CHANGE',
                          style: TextStyle(
                            color: Color(0xFFFF3E6C),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          address,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              phoneNumber,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Payment method section with improved design
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.payment,
                        color: Color(0xFFFF3E6C),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'PAYMENT METHOD',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Cash on Delivery Option
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        paymentMethod = 'cash-on-delivery';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            paymentMethod == 'cash-on-delivery'
                                ? const Color(0xFFFEF2F5)
                                : Colors.white,
                        border: Border.all(
                          color:
                              paymentMethod == 'cash-on-delivery'
                                  ? const Color(0xFFFF3E6C)
                                  : Colors.grey[300]!,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: 'cash-on-delivery',
                            groupValue: paymentMethod,
                            activeColor: const Color(0xFFFF3E6C),
                            onChanged: (value) {
                              setState(() {
                                paymentMethod = value!;
                              });
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.money,
                              color: Color(0xFFFF3E6C),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cash on Delivery',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Pay when your order arrives',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Online Payment Option
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        paymentMethod = 'online';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            paymentMethod == 'online'
                                ? const Color(0xFFFEF2F5)
                                : Colors.white,
                        border: Border.all(
                          color:
                              paymentMethod == 'online'
                                  ? const Color(0xFFFF3E6C)
                                  : Colors.grey[300]!,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: 'online',
                            groupValue: paymentMethod,
                            activeColor: const Color(0xFFFF3E6C),
                            onChanged: (value) {
                              setState(() {
                                paymentMethod = value!;
                              });
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.credit_card,
                              color: Color(0xFFFF3E6C),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Online Payment',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Cards, UPI, NetBanking, Wallets',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
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
          ),

          const SizedBox(height: 16),

          // Price details section with improved design
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),

          const SizedBox(height: 100), // Add some space at the bottom
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ElevatedButton(
          onPressed: onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF3E6C),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'PROCEED TO PAY ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }
}
