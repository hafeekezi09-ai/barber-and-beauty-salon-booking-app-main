import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const Icon(Icons.payment, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              "Choose your payment method",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Payment via Card")),
                );
              },
              icon: const Icon(Icons.credit_card),
              label: const Text("Pay with Card"),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Payment via UPI")),
                );
              },
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text("Pay with UPI"),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                // Integrate payment gateway here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Payment via Wallet")),
                );
              },
              icon: const Icon(Icons.account_balance),
              label: const Text("Pay with Wallet"),
            ),
          ],
        ),
      ),
    );
  }
}
