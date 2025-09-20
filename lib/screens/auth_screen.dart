import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _homeCityController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  AuthMode _authMode = AuthMode.email;
  String _selectedCurrency = 'USD';

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY'];

  @override
  void dispose() {
    _nameController.dispose();
    _homeCityController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // App logo/icon
              Icon(
                Icons.flight_takeoff,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Travel Tracker',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Record, organize, and relive your adventures',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Auth mode selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How would you like to get started?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildAuthModeSelector(),
                      const SizedBox(height: 24),
                      
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Name field
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Your Name',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Home city field
                            TextFormField(
                              controller: _homeCityController,
                              decoration: const InputDecoration(
                                labelText: 'Home City',
                                prefixIcon: Icon(Icons.home),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter your home city';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Email or Phone field based on mode
                            if (_authMode == AuthMode.email)
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email Address',
                                  prefixIcon: Icon(Icons.email),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter your email';
                                  }
                                  if (!value!.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              )
                            else if (_authMode == AuthMode.phone)
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  prefixIcon: Icon(Icons.phone),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter your phone number';
                                  }
                                  return null;
                                },
                              ),
                            
                            if (_authMode != AuthMode.guest) const SizedBox(height: 16),
                            
                            // Currency selector
                            DropdownButtonFormField<String>(
                              value: _selectedCurrency,
                              decoration: const InputDecoration(
                                labelText: 'Preferred Currency',
                                prefixIcon: Icon(Icons.attach_money),
                                border: OutlineInputBorder(),
                              ),
                              items: _currencies.map((currency) {
                                return DropdownMenuItem(
                                  value: currency,
                                  child: Text(currency),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedCurrency = value;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Get started button
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading ? null : _handleGetStarted,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: authProvider.isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(_getButtonText()),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Error display
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (authProvider.error != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Card(
                        color: Colors.red[50],
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(Icons.error, color: Colors.red[700]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authProvider.error!,
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthModeSelector() {
    return Column(
      children: AuthMode.values.map((mode) {
        return RadioListTile<AuthMode>(
          title: Text(_getAuthModeTitle(mode)),
          subtitle: Text(_getAuthModeSubtitle(mode)),
          value: mode,
          groupValue: _authMode,
          onChanged: (AuthMode? value) {
            if (value != null) {
              setState(() {
                _authMode = value;
              });
            }
          },
        );
      }).toList(),
    );
  }

  String _getAuthModeTitle(AuthMode mode) {
    switch (mode) {
      case AuthMode.email:
        return 'Sign up with Email';
      case AuthMode.phone:
        return 'Sign up with Phone';
      case AuthMode.guest:
        return 'Continue as Guest';
    }
  }

  String _getAuthModeSubtitle(AuthMode mode) {
    switch (mode) {
      case AuthMode.email:
        return 'Create an account with your email address';
      case AuthMode.phone:
        return 'Create an account with your phone number';
      case AuthMode.guest:
        return 'Try the app without creating an account';
    }
  }

  String _getButtonText() {
    switch (_authMode) {
      case AuthMode.email:
        return 'Sign Up with Email';
      case AuthMode.phone:
        return 'Sign Up with Phone';
      case AuthMode.guest:
        return 'Continue as Guest';
    }
  }

  Future<void> _handleGetStarted() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    bool success = false;

    switch (_authMode) {
      case AuthMode.email:
        success = await authProvider.signUpWithEmail(
          _emailController.text.trim(),
          _nameController.text.trim(),
          _homeCityController.text.trim(),
          preferredCurrency: _selectedCurrency,
        );
        break;
      case AuthMode.phone:
        success = await authProvider.signUpWithPhone(
          _phoneController.text.trim(),
          _nameController.text.trim(),
          _homeCityController.text.trim(),
          preferredCurrency: _selectedCurrency,
        );
        break;
      case AuthMode.guest:
        success = await authProvider.continueAsGuest(
          _nameController.text.trim(),
          _homeCityController.text.trim(),
          preferredCurrency: _selectedCurrency,
        );
        break;
    }

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to get started'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

enum AuthMode { email, phone, guest }