import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neck_check/features/camera/presentation/bloc/camera_bloc.dart';

import 'camera_provider.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        if (state is CameraLoaded) {
          return const _CameraLoadedView();
        } else if (state is CameraError) {
          return _CameraErrorView(message: state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _CameraLoadedView extends StatelessWidget {
  const _CameraLoadedView();

  @override
  Widget build(BuildContext context) {
    final controller = CameraProvider.of(context);

    if (controller.value.isInitialized) {
      if (controller.description.lensDirection == CameraLensDirection.front) {
        return Transform.scale(
          scaleX: -1.0, // 좌우반전 적용
          child: controller.buildPreview(),
        );
      }

      return controller.buildPreview();
    }

    return const SizedBox.shrink();
  }
}

class _CameraErrorView extends StatelessWidget {
  const _CameraErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message, style: TextStyle(color: Colors.white)));
  }
}
