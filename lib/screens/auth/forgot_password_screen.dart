// import 'package:flutter/material.dart';
// import 'package:mpitana/common/services/auth_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   @override
//   _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final AuthService _authService = AuthService();
//   bool _isLoading = false;
//   bool _resetEmailSent = false;

//   Future<void> _handleResetPassword() async {
//     if (_emailController.text.isEmpty) {
//       _showSnackBar('Please enter your email address', Colors.orange);
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await _authService.resetPassword(_emailController.text.trim());
//       setState(() {
//         _resetEmailSent = true;
//       });
//     } on FirebaseAuthException catch (e) {
//       String errorMessage;
//       switch (e.code) {
//         case 'invalid-email':
//           errorMessage = 'The email address is not valid.';
//           break;
//         case 'user-not-found':
//           errorMessage = 'No user found with this email address.';
//           break;
//         default:
//           errorMessage = 'An error occurred. Please try again.';
//       }
//       _showSnackBar(errorMessage, Colors.red);
//     } catch (e) {
//       _showSnackBar('Error: ${e.toString()}', Colors.red);
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   void _showSnackBar(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: color,
//         duration: Duration(seconds: 3),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Reset Password'),
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         foregroundColor: Theme.of(context).colorScheme.onSurface,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Theme.of(context).colorScheme.primary.withOpacity(0.3),
//               Theme.of(context).colorScheme.secondary.withOpacity(0.2),
//               Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               child: Container(
//                 margin: EdgeInsets.symmetric(horizontal: 30),
//                 padding: EdgeInsets.all(30),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.surface,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
//                       blurRadius: 20,
//                       offset: Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: _resetEmailSent ? _buildSuccessContent() : _buildResetForm(),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildResetForm() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           'Reset Password',
//           style: TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).colorScheme.onSurface,
//           ),
//         ),
//         SizedBox(height: 20),
//         Text(
//           'Enter your email address and we\'ll send you a link to reset your password.',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 16,
//             color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
//           ),
//         ),
//         SizedBox(height: 30),
//         TextField(
//           controller: _emailController,
//           decoration: InputDecoration(
//             hintText: 'Email address',
//             hintStyle: TextStyle(
//               color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
//               fontSize: 16,
//             ),
//             filled: true,
//             fillColor: Theme.of(context).colorScheme.background,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
//             ),
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: 20,
//               vertical: 18,
//             ),
//           ),
//           keyboardType: TextInputType.emailAddress,
//           style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
//         ),
//         SizedBox(height: 30),
//         SizedBox(
//           width: double.infinity,
//           height: 55,
//           child: ElevatedButton(
//             onPressed: _isLoading ? null : _handleResetPassword,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Theme.of(context).colorScheme.primary,
//               foregroundColor: Theme.of(context).colorScheme.onPrimary,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 3,
//             ),
//             child: _isLoading
//                 ? SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                           Theme.of(context).colorScheme.onPrimary),
//                     ),
//                   )
//                 : Text(
//                     'Send Reset Link',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSuccessContent() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(
//           Icons.check_circle_outline,
//           size: 80,
//           color: Theme.of(context).colorScheme.primary,
//         ),
//         SizedBox(height: 20),
//         Text(
//           'Email Sent!',
//           style: TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).colorScheme.onSurface,
//           ),
//         ),
//         SizedBox(height: 20),
//         Text(
//           'We\'ve sent a password reset link to:\n${_emailController.text}',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 16,
//             color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
//           ),
//         ),
//         SizedBox(height: 20),
//         Text(
//           'Please check your email and follow the instructions to reset your password.',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 16,
//             color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
//           ),
//         ),
//         SizedBox(height: 30),
//         SizedBox(
//           width: double.infinity,
//           height: 55,
//           child: ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Theme.of(context).colorScheme.primary,
//               foregroundColor: Theme.of(context).colorScheme.onPrimary,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 3,
//             ),
//             child: Text(
//               'Back to Login',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }
// }
