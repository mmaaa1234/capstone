import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc() : super(CameraInitial()) {
    on<CameraStarted>(onCameraStarted);
    on<CameraChangePressed>(transformer: droppable(), onCameraChangePressed);
  }

  FutureOr<void> onCameraStarted(
    CameraStarted event,
    Emitter<CameraState> emit,
  ) async {
    // 카메라 탐색
    final cameras = await availableCameras();

    // 카메라가 없으면 return
    if (cameras.isEmpty) {
      return emit(CameraError(message: 'No Camera available'));
    }

    // 전면 카메라 선택
    int index = cameras.indexWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
    );

    // 전면 카메라가 없으면 첫번째 카메라
    if (index == -1) {
      index = 0;
    }

    emit(CameraLoaded(index: index, cameras: cameras));
  }

  FutureOr<void> onCameraChangePressed(
    CameraChangePressed event,
    Emitter<CameraState> emit,
  ) async {
    final controller = event.controller;

    if (state is CameraLoaded && controller.value.isInitialized) {
      final cameras = (state as CameraLoaded).cameras;

      // 카메라 전환하기
      final index = ((state as CameraLoaded).index + 1) % cameras.length;
      final camera = cameras[index];

      await controller.setDescription(camera);

      emit(CameraLoaded(index: index, cameras: cameras));
    }
  }
}
