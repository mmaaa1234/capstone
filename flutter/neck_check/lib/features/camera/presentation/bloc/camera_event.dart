part of 'camera_bloc.dart';

sealed class CameraEvent {
  const CameraEvent();
}

final class CameraStarted extends CameraEvent {
  const CameraStarted();
}

final class CameraChangePressed extends CameraEvent {
  final CameraController controller;

  const CameraChangePressed({required this.controller});
}
