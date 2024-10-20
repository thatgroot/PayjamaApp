// to function
import 'package:go_router/go_router.dart';

void to(context, String route) {
  GoRouter.of(context).go(route);
}
