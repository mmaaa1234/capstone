import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Home Page'),
            IconButton(
              onPressed: () {
                context.go('/camera');
              },
              icon: Icon(Icons.photo_camera),
            ),
          ],
        ),
      ),
    );
  }
}
