import 'package:flutter/material.dart';
import 'package:neck_check/features/camera/presentation/camera_presentation.dart';
import 'package:neck_check/app/router/close_home_button.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            CameraView(),
            Align(alignment: Alignment.topLeft, child: CameraCloseButton()),
            Align(
              alignment: Alignment.bottomRight,
              child: CameraChangeButton(),
            ),
          ],
        ),
      ),
    );
  }
}
