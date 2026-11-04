import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/screen_manager.dart';
import '../utils/enums.dart';


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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.read<ScreenManager>().setScreen(Screens.login),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Not Implemented Yet',
            style: TextStyle(fontSize: 22,
            fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
             Image.asset('assets/images/notImplemented.png', height: 400, ), 
          ],
        )      
        )
    );
  }
}