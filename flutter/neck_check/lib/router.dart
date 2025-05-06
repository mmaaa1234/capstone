import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neck_check/features/auth/auth_page.dart';
import 'package:neck_check/features/camera/presentation/bloc/camera_bloc.dart';
import 'package:neck_check/features/camera/presentation/camera_presentation.dart';
import 'package:neck_check/pages/home_page.dart';
import 'package:neck_check/pages/camera_page.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
        routes: [
          // 카메라 기능 관련 화면
          GoRoute(
            path: 'camera',
            builder: (context, state) {
              const page = CameraPage();

              return BlocProvider(
                create: (context) => CameraBloc()..add(CameraStarted()),
                // CameraLoaded 일때만 CameraController 생성
                child: BlocBuilder<CameraBloc, CameraState>(
                  builder: (context, state) {
                    // 카메라를 무사히 가져오면 컨트롤러 생성
                    if (state is CameraLoaded) {
                      return CameraProviderWidget(
                        camera: state.cameras[state.index],
                        child: page,
                      );
                    }

                    // 카메라가 없으면 컨트롤러 제공 안함
                    return page;
                  },
                ),
              );
            },
          ),
        ],
      ),
    ],
  );
}
