import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../services/screen_manager.dart';
import '../utils/enums.dart';

class LoginScreen extends StatelessWidget
{
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Login Screen'),
      ),

      body: Center(
        child: ElevatedButton(
          onPressed: () => context.read<ScreenManager>().setScreen(Screens.home),
          child: const Text('Continue'),

          /*
          slivers: [
            SliverAppBar()
            SliverAppBar()
            SliverAppBar()

            backgroundColor: Colors.brue,
            height: 140,
            flecibleSpace: FlexibleSpaceBar(
              background: padding,
              padding: const EdgeInserts.all(16),
              child: Clumn(

              )
            )


          ]
          *children:[
          _buildQuickAction(Icons: home, label: 'Home')
          _buildQuickAction(Icons: workout, label: 'Workout log')
          _buildQuickAction(Icons: avatar, label: 'Avatar creation')
          ]*/
         ),
      ),
    );
  }
}
