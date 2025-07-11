import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mpitana/screens/auth/sign_up_screen.dart';
import 'package:mpitana/screens/home/home_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    debugPrint("Login button pressed");
    setState(() {
      _isLoading = true;
    });

    try {
      // Check location services
      debugPrint("Checking location services...");
      final serviceStatus = await Permission.location.serviceStatus;
      debugPrint("Location services status: $serviceStatus");
      if (!serviceStatus.isEnabled) {
        _showSnackBar(
            'Location services are disabled. Please enable them in device settings.',
            Colors.red);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Check permission status
      debugPrint("Checking permission status...");
      final status = await Permission.location.status;
      debugPrint("Current permission status: $status");

      if (status.isGranted) {
        _showSnackBar('Location permission already granted!', Colors.green);
        _navigateToHome();
      } else {
        // Attempt to request permission
        debugPrint("Requesting location permission...");
        final newStatus = await Permission.location.request();
        debugPrint("Permission request result: $newStatus");
        debugPrint(
            "Is granted: ${newStatus.isGranted}, Is denied: ${newStatus.isDenied}, Is permanently denied: ${newStatus.isPermanentlyDenied}");

        if (newStatus.isGranted) {
          _showSnackBar(
              'Location permission granted! You can now use Google Maps.',
              Colors.green);
          _navigateToHome();
        } else if (newStatus.isPermanentlyDenied) {
          _showSnackBar(
              'Location permission permanently denied. Please enable it in app settings.',
              Colors.red);
          debugPrint("Opening app settings...");
          await openAppSettings();
          // Re-check permission after settings
          final recheckStatus = await Permission.location.status;
          debugPrint("Permission status after settings: $recheckStatus");
          if (recheckStatus.isGranted) {
            _showSnackBar('Location permission granted!', Colors.green);
            _navigateToHome();
          } else {
            _showSnackBar('Location permission still denied.', Colors.orange);
            _navigateToHome();
          }
        } else {
          _showSnackBar('Location permission denied.', Colors.orange);
          _navigateToHome();
        }
      }
    } catch (e) {
      debugPrint("Error in permission flow: $e");
      _showSnackBar('Error requesting permission: $e', Colors.red);
      _navigateToHome();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToHome() {
    debugPrint("Navigating to HomeScreen");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  void _showSnackBar(String message, Color color) {
    debugPrint("Showing snackbar: $message");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color == Colors.red
            ? Theme.of(context).colorScheme.error
            : color == Colors.green
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary, // Assuming secondary can be used for orange/warning
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/burundi_landscape.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.3),
                Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                Theme.of(context).colorScheme.tertiary.withOpacity(0.3), // Consider defining tertiary in your color scheme
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header with flag and app name
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.error, // Represents red from the flag
                              Theme.of(context).colorScheme.onPrimary, // Represents white from the flag
                              Theme.of(context).colorScheme.surface, // Represents green from the flag, assuming surface can be green in the theme
                            ],
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: Icon(
                              Icons.star,
                              color: Theme.of(context).colorScheme.error, // Red star
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Text(
                        'Mpitana',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.2),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.menu,
                        color: Theme.of(context).colorScheme.onBackground,
                        size: 28,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        padding: EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 40),
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: 'Email address',
                                hintStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  fontSize: 16,
                                ),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  fontSize: 16,
                                ),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                            ),
                            SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                                        ),
                                      )
                                    : Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    print('Forgot password pressed');
                                  },
                                  child: Text(
                                    'Forgot Password',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => SignUpPage()),
                                    );
                                  },
                                  child: Text(
                                    'Create Account',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}