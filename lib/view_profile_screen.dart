import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewProfileScreen extends StatefulWidget {
  final User user;
  
  const ViewProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ViewProfileScreenState createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;
  late TextEditingController _nameController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _nameController = TextEditingController(text: widget.user.displayName ?? '');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[700],
        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  // Here you would implement updating profile logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated!'))
                  );
                }
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: "Profile"),
            Tab(icon: Icon(Icons.settings), text: "Settings"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: Colors.blue[700],
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: widget.user.photoURL != null
                              ? NetworkImage(widget.user.photoURL!)
                              : null,
                          child: widget.user.photoURL == null
                              ? Text(
                                  _getInitials(),
                                  style: const TextStyle(fontSize: 40, color: Colors.blue),
                                )
                              : null,
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, size: 18),
                                onPressed: () {
                                  // Implement photo upload logic
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Photo upload feature coming soon!'))
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _isEditing
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: TextField(
                              controller: _nameController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        : Text(
                            widget.user.displayName ?? 'No Name Set',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    const SizedBox(height: 8),
                    Text(
                      widget.user.email ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildInfoCards(),
        ],
      ),
    );
  }

  String _getInitials() {
    if (widget.user.displayName == null || widget.user.displayName!.isEmpty) {
      return '?';
    }
    final nameParts = widget.user.displayName!.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    }
    return nameParts[0][0];
  }

  Widget _buildInfoCards() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Account Information'),
          _buildInfoCard(
            'Phone Number',
            widget.user.phoneNumber ?? 'Not set',
            Icons.phone,
            _isEditing ? () {
              // Implement phone update logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Phone update feature coming soon!'))
              );
            } : null,
          ),
          _buildInfoCard(
            'Account Created',
            widget.user.metadata.creationTime?.toString().split(' ')[0] ?? 'Unknown',
            Icons.calendar_today,
            null,
          ),
          _buildInfoCard(
            'Email Verified',
            widget.user.emailVerified ? 'Yes' : 'No',
            Icons.verified,
            !widget.user.emailVerified && _isEditing ? () {
              // Implement verification logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verification email sent!'))
              );
            } : null,
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Security'),
          _buildInfoCard(
            'Password',
            '••••••••',
            Icons.lock,
            _isEditing ? () {
              // Implement password change logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password change feature coming soon!'))
              );
            } : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Function()? onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[50],
          child: Icon(icon, color: Colors.blue[700]),
        ),
        title: Text(title),
        subtitle: Text(value),
        trailing: onTap != null
            ? IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: onTap,
              )
            : null,
      ),
    );
  }

  Widget _buildSettingsTab() {
    final settingsItems = [
      {'title': 'Notifications', 'icon': Icons.notifications},
      {'title': 'Privacy', 'icon': Icons.privacy_tip},
      {'title': 'Appearance', 'icon': Icons.color_lens},
      {'title': 'Language', 'icon': Icons.language},
      {'title': 'Help & Support', 'icon': Icons.help},
      {'title': 'About', 'icon': Icons.info},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: settingsItems.length + 1, // +1 for logout button
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        if (index < settingsItems.length) {
          final item = settingsItems[index];
          return ListTile(
            leading: Icon(item['icon'] as IconData, color: Colors.blue[700]),
            title: Text(item['title'] as String),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item['title']} settings coming soon!'))
              );
            },
          );
        } else {
          // Logout button
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Implement logout logic
                          FirebaseAuth.instance.signOut();
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Go back to login page
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}