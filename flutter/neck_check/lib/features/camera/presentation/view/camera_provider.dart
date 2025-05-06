import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neck_check/features/camera/presentation/bloc/camera_bloc.dart';

class CameraProvider extends InheritedNotifier<CameraController> {
  const CameraProvider({
    super.key,
    required super.notifier,
    required super.child,
  });

  static CameraController of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<CameraProvider>();
    if (provider == null) {
      throw FlutterError('CameraProvider를 찾을 수 없습니다');
    }
    return provider.notifier!;
  }
}

class CameraProviderWidget extends StatefulWidget {
  const CameraProviderWidget({
    super.key,
    required this.camera,
    required this.child,
  });

  final CameraDescription camera;
  final Widget child;

  @override
  State<CameraProviderWidget> createState() => _CameraProviderWidgetState();
}

class _CameraProviderWidgetState extends State<CameraProviderWidget> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();

    // 컨트롤러 생성
    controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    // 컨트롤러 초기화
    controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraProvider(notifier: controller, child: widget.child);
  }
}
