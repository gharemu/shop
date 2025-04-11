import 'package:flutter/material.dart';

class DeleteItemScreen extends StatelessWidget {
  const DeleteItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController idController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Delete Item", style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 20),
        TextField(
          controller: idController,
          decoration: InputDecoration(labelText: "Item ID"),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Call API to delete item
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Item deleted (simulated)")),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text("Delete Item"),
        ),
      ],
    );
  }
}
