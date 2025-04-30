import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_service.dart';
import 'user_provider.dart';
import 'package:Deals/screen/checkout_page.dart';

class ProfilePage extends StatefulWidget {
  final bool fromCheckout;

  const ProfilePage({Key? key, this.fromCheckout = false}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  bool isEditing = false;
  bool isSaving = false;
  bool isLoadingOrders = true;
  List<dynamic> orders = [];
  late TabController _tabController;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final nationalityController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchProfile();
    fetchOrders();
  }

  Future fetchProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!userProvider.isLoggedIn) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to view your profile.")),
      );
      return;
    }

    // First try to get data from local storage
    if (userProvider.user != null) {
      final user = userProvider.user!;
      nameController.text = user["name"] ?? "";
      emailController.text = user["email"] ?? "";
      phoneController.text = user["phone_number"] ?? "";
      nationalityController.text = user["nationality"] ?? "";
      addressController.text = user["address"] ?? "";
    }

    // Then fetch latest data from server
    try {
      final response = await ApiService.getProfile(userProvider.token!);

      if (response["success"]) {
        final user = response["data"];
        nameController.text = user["name"] ?? "";
        emailController.text = user["email"] ?? "";
        phoneController.text = user["phone_number"] ?? "";
        nationalityController.text = user["nationality"] ?? "";
        addressController.text = user["address"] ?? "";

        // Update local storage with latest data
        await userProvider.updateUserData(user);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response["message"])));
      }
    } catch (e) {
      print("Error fetching profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load profile. Please try again."),
        ),
      );
    }

    setState(() => isLoading = false);
  }

  Future fetchOrders() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!userProvider.isLoggedIn) {
      setState(() => isLoadingOrders = false);
      return;
    }

    try {
      final response = await ApiService.getOrders(userProvider.token!);

      if (response["success"]) {
        setState(() {
          orders = response["data"] ?? [];
          isLoadingOrders = false;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response["message"])));
        setState(() => isLoadingOrders = false);
      }
    } catch (e) {
      print("Error fetching orders: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load orders. Please try again."),
        ),
      );
      setState(() => isLoadingOrders = false);
    }
  }

  Future saveProfile() async {
    setState(() => isSaving = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final updatedData = {
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "phone_number": phoneController.text.trim(),
      "nationality": nationalityController.text.trim(),
      "address": addressController.text.trim(),
    };

    try {
      final response = await ApiService.updateProfile(
        updatedData,
        userProvider.token!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"]),
          backgroundColor: response["success"] ? Colors.green : Colors.red,
        ),
      );

      if (response["success"]) {
        // Update local storage with new data
        await userProvider.updateUserData(updatedData);
        setState(() => isEditing = false);

        // If we came from checkout, return to checkout page
        if (widget.fromCheckout) {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CheckoutPage(comingFromProfile: true),
            ),
          );
        }
      }
    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to save profile. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  String getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return '#4CAF50'; // Green
      case 'shipped':
        return '#2196F3'; // Blue
      case 'processing':
        return '#FF9800'; // Orange
      case 'cancelled':
        return '#F44336'; // Red
      case 'pending':
        return '#9E9E9E'; // Grey
      default:
        return '#9E9E9E'; // Grey
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.fromCheckout && !isEditing)
            TextButton(
              onPressed: () {
                setState(() => isEditing = true);
              },
              child: const Text(
                "Edit",
                style: TextStyle(
                  color: Color(0xFFFF3E6C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFFF3E6C),
              labelColor: const Color(0xFFFF3E6C),
              unselectedLabelColor: Colors.grey,
              tabs: const [Tab(text: "PROFILE"), Tab(text: "MY ORDERS")],
            ),
          ),
        ),
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF3E6C)),
              )
              : Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  if (!userProvider.isLoggedIn) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_circle_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Please login to view your profile",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF3E6C),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      // PROFILE TAB
                      buildProfileTab(userProvider),

                      // MY ORDERS TAB
                      buildOrdersTab(),
                    ],
                  );
                },
              ),
    );
  }

  Widget buildProfileTab(UserProvider userProvider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header with gradient background
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFF3E6C),
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFFEE2EB),
                    child: Text(
                      nameController.text.isNotEmpty
                          ? nameController.text[0].toUpperCase()
                          : "U",
                      style: const TextStyle(
                        fontSize: 50,
                        color: Color(0xFFFF3E6C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  nameController.text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  emailController.text,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Personal Information Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, color: Color(0xFFFF3E6C)),
                    const SizedBox(width: 10),
                    const Text(
                      "Personal Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (!widget.fromCheckout && !isEditing)
                      TextButton.icon(
                        onPressed: () {
                          setState(() => isEditing = true);
                        },
                        icon: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Color(0xFFFF3E6C),
                        ),
                        label: const Text(
                          "Edit",
                          style: TextStyle(
                            color: Color(0xFFFF3E6C),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 15),

                // Information fields with improved design
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      buildProfileField(
                        controller: nameController,
                        label: "Full Name",
                        icon: Icons.person_outline,
                        isEditing: isEditing,
                        isHighlighted: widget.fromCheckout,
                      ),
                      const SizedBox(height: 16),
                      buildProfileField(
                        controller: emailController,
                        label: "Email Address",
                        icon: Icons.email_outlined,
                        isEditing: isEditing,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      buildProfileField(
                        controller: phoneController,
                        label: "Phone Number",
                        icon: Icons.phone_outlined,
                        isEditing: isEditing,
                        keyboardType: TextInputType.phone,
                        isHighlighted: widget.fromCheckout,
                      ),
                      const SizedBox(height: 16),
                      buildProfileField(
                        controller: nationalityController,
                        label: "Nationality",
                        icon: Icons.flag_outlined,
                        isEditing: isEditing,
                      ),
                      const SizedBox(height: 16),
                      buildProfileField(
                        controller: addressController,
                        label: "Delivery Address",
                        icon: Icons.home_outlined,
                        isEditing: isEditing,
                        maxLines: 3,
                        isHighlighted: widget.fromCheckout,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Buttons section
                if (isEditing)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isEditing = false;
                              // Reset to original values
                              fetchProfile();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "CANCEL",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSaving ? null : saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF3E6C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child:
                              isSaving
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    "SAVE CHANGES",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  )
                else if (!widget.fromCheckout)
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        userProvider.logout();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Logged out successfully"),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.red,
                        size: 20,
                      ),
                      label: const Text(
                        "LOGOUT",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOrdersTab() {
    if (isLoadingOrders) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF3E6C)),
      );
    }

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "No orders yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your order history will appear here",
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/deals');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3E6C),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Start Shopping",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.grey[50],
      child: RefreshIndicator(
        onRefresh: fetchOrders,
        color: const Color(0xFFFF3E6C),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final formattedDate = DateTime.parse(
              order['created_at'] ?? DateTime.now().toString(),
            ).toString().substring(0, 10);
            final orderStatus = order['status'] ?? 'Processing';
            final statusColor = getOrderStatusColor(orderStatus);

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          color: Color(0xFFFF3E6C),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order #${order['id']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Placed on $formattedDate",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(
                              int.parse(
                                    statusColor.substring(1, 7),
                                    radix: 16,
                                  ) +
                                  0xFF000000,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            orderStatus,
                            style: TextStyle(
                              color: Color(
                                int.parse(
                                      statusColor.substring(1, 7),
                                      radix: 16,
                                    ) +
                                    0xFF000000,
                              ),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Order items
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order['items']?.length ?? 0,
                    itemBuilder: (context, itemIndex) {
                      final item = order['items'][itemIndex];
                      return ListTile(
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              item['image_url'] != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item['image_url'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const Icon(
                                          Icons.image_not_supported,
                                        );
                                      },
                                    ),
                                  )
                                  : const Icon(Icons.image_outlined),
                        ),
                        title: Text(
                          item['product_name'] ?? 'Unknown Product',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Qty: ${item['quantity']} x ${item['price'] != null ? '₹${item['price']}' : 'Price not available'}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    },
                  ),

                  const Divider(),

                  // Order total
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Amount:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "₹${order['total_amount'] ?? '0.00'}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFFFF3E6C),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // View order details
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => OrderDetailsPage(orderId: order['id']),
                              //   ),
                              // );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFFF3E6C),
                              side: const BorderSide(color: Color(0xFFFF3E6C)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text("VIEW DETAILS"),
                          ),
                        ),
                        if (orderStatus.toLowerCase() == 'delivered')
                          const SizedBox(width: 12),
                        if (orderStatus.toLowerCase() == 'delivered')
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Write review
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF3E6C),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text("WRITE REVIEW"),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildProfileField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isEditing,
    bool isHighlighted = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isHighlighted && !isEditing ? const Color(0xFFFFF5F7) : null,
        borderRadius: BorderRadius.circular(8),
        border:
            isHighlighted && !isEditing
                ? Border.all(color: const Color(0xFFFF3E6C), width: 1)
                : null,
      ),
      padding:
          isHighlighted && !isEditing
              ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
              : EdgeInsets.zero,
      child: TextField(
        controller: controller,
        enabled: isEditing,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 16,
          color: isEditing ? Colors.black87 : Colors.black54,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: isHighlighted ? const Color(0xFFFF3E6C) : Colors.grey,
          ),
          labelStyle: TextStyle(
            color: isHighlighted ? const Color(0xFFFF3E6C) : null,
          ),
          border:
              isEditing
                  ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          isHighlighted
                              ? const Color(0xFFFF3E6C)
                              : Colors.grey.shade300,
                    ),
                  )
                  : InputBorder.none,
          enabledBorder:
              isEditing
                  ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          isHighlighted
                              ? const Color(0xFFFF3E6C)
                              : Colors.grey.shade300,
                    ),
                  )
                  : InputBorder.none,
          focusedBorder:
              isEditing
                  ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFFF3E6C),
                      width: 2,
                    ),
                  )
                  : InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    nationalityController.dispose();
    addressController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
