part of 'camera_bloc.dart';

sealed class CameraState {
  const CameraState();
}

final class CameraInitial extends CameraState {
  const CameraInitial();
}

final class CameraLoaded extends CameraState {
  const CameraLoaded({required this.index, required this.cameras});

  final int index;
  final List<CameraDescription> cameras;
}

final class CameraError extends CameraState {
  const CameraError({required this.message});

  final String message;
}
