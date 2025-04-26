import 'package:Deals/screen/cashondel.dart';
import 'package:Deals/screen/onlinepayment.dart';
import 'package:flutter/material.dart';
import 'package:Deals/services/checkoutservice.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    loadCheckoutData();
  }

  Future<void> loadCheckoutData() async {
    try {
      final data = await _checkoutService.getCheckout();
      setState(() {
        name = data['address']['name'] ?? '';
        address = data['address']['address'] ?? '';
        phoneNumber = data['address']['phone_number'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load checkout details.';
        isLoading = false;
      });
    }
  }

  void onContinue() {
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
    Navigator.pushNamed(context, '/userProfile');
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
        title: const Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('Delivery Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 18)),
                        TextButton(
                          onPressed: gotoProfile,
                          child: const Text('EDIT', style: TextStyle(color: Colors.blue)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(address),
                    const SizedBox(height: 8),
                    Text('Phone: $phoneNumber'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Payment Method', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  RadioListTile(
                    title: const Text('Cash on Delivery'),
                    value: 'cash-on-delivery',
                    groupValue: paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        paymentMethod = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('Online Payment'),
                    value: 'online',
                    groupValue: paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        paymentMethod = value.toString();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onContinue,
              child: const Text('CONTINUE'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
