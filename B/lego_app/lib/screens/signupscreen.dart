import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../service/auth_service.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _shopnameController = TextEditingController();
  String _selectedRole = 'seller'; // Default role
  String _errorMessage = '';

  final List<String> _roles = ['seller', 'manager', 'admin', 'buyer'];

  Future<void> _registerUser() async {
    try {
      await _authService.registerWithEmailAndPassword(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        password2: _password2Controller.text.trim(),
        role: _selectedRole,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        shopname: _shopnameController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User registered successfully'),
      ));
      Navigator.pop(context); // Navigate back after registration
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to register: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'.tr),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'.tr),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'.tr),
              obscureText: true,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _password2Controller,
              decoration: InputDecoration(labelText: 'Password'.tr),
              obscureText: true,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(labelText: 'Role'.tr),
              dropdownColor: Colors.black,
              items: _roles.map((String role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue!;
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'.tr),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'.tr),
              maxLines: 2,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _shopnameController,
              decoration: InputDecoration(labelText: 'Shop Name'.tr),
              maxLines: 2,
            ),
            SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _registerUser,
              child: Text('Sign Up'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
