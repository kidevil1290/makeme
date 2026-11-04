
import 'package:flutter/material.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
 
  @override
  State<SignupScreen> createState() => _SignupScreenState();
  }

  class _SignupScreenState extends State<SignupScreen> {
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _confirmController = TextEditingController();
 
    @override
    void dispose() {
      _emailController.dispose();
      _passwordController.dispose();
      _confirmController.dispose();
      super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  } 
}