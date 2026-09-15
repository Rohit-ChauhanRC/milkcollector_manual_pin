part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const LOGIN = _Paths.LOGIN;
  static const PIN = _Paths.PIN;
  static const HOME = _Paths.HOME;
}

abstract class _Paths {
  _Paths._();
  static const LOGIN = '/login';
  static const PIN = '/pin';
  static const HOME = '/home';
}
