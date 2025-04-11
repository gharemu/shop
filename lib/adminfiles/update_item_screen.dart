import 'package:flutter/material.dart';

class UpdateItemScreen extends StatelessWidget {
  const UpdateItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController idController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Update Item", style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 20),
          TextField(
            controller: idController,
            decoration: InputDecoration(labelText: "Item ID"),
          ),
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: "New Name"),
          ),
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "New Price"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Call API to update item
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Item updated (simulated)")),
              );
            },
            child: Text("Update Item"),
          ),
        ],
      ),
    );
  }
}
