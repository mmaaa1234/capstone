import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neck_check/features/camera/presentation/bloc/camera_bloc.dart';

import 'camera_provider.dart';

class CameraChangeButton extends StatelessWidget {
  const CameraChangeButton({super.key});

  @override
  Widget build(BuildContext context) {
    bool isActive = context.select<CameraBloc, bool>(
      (bloc) => bloc.state is CameraLoaded,
    );

    return IconButton(
      onPressed:
          isActive
              ? () {
                final controller = CameraProvider.of(context);

                context.read<CameraBloc>().add(
                  CameraChangePressed(controller: controller),
                );
              }
              : null,
      icon: const Icon(Icons.cameraswitch),
      color: Colors.white,
    );
  }
}
