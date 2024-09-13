import 'package:flutter/material.dart';
import 'package:pyjama_runner/screens/character_display_screen.dart';

class UserProfile extends StatelessWidget {
  UserProfile({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CharacterDisplayScreen(),
              ),
            ),
          },
        ),
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF24243E),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF24243E), Color(0xFF302B63), Color(0xFF0F0C29)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 56,
                backgroundImage:
                    AssetImage('assets/icons/navigation/profile.png'),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFED127),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kayna Alisa',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              width: 172,
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        BorderSide.none, // This removes the default border
                  ),
                ),
                style: const TextStyle(
                  color: Color(0xFF6261D4),
                  fontSize: 12,
                ),
                controller: TextEditingController()
                  ..text = 'kaynaaslisaa@gmail.com',
              ),
            ),
            const SizedBox(height: 40),
            _buildMenuItem(Icons.edit, 'Edit Profile'),
            _buildMenuItem(Icons.lock, 'Change Password'),
            _buildMenuItem(Icons.settings, 'Settings'),
            _buildMenuItem(Icons.exit_to_app, 'Logout', isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {bool isLogout = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(icon,
              color:
                  isLogout ? const Color(0xFFEC5D5D) : const Color(0xFFFED127)),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isLogout ? const Color(0xFFEC5D5D) : Colors.white,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
    );
  }
}
