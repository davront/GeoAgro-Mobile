import 'package:flutter/material.dart';

import 'remote_controller.dart';

// class InheritedRemoteNotifier extends InheritedNotifier<RemoteController> {
//   const InheritedRemoteNotifier({
//     super.key,
//     required super.child,
//     required RemoteController remoteController,
//   }) : super(notifier: remoteController);

//   static RemoteController? maybeOf(BuildContext context, {bool listen = true}) {
//     if (listen) {
//       return context.dependOnInheritedWidgetOfExactType<InheritedRemoteNotifier>()?.notifier;
//     } else {
//       final inhW = context.getElementForInheritedWidgetOfExactType<InheritedRemoteNotifier>()?.widget;
//       return inhW is InheritedRemoteNotifier ? inhW.notifier : null;
//     }
//   }
// }

class InheritedRemoteNotifier extends InheritedNotifier<RemoteController> {
  const InheritedRemoteNotifier({
    super.key,
    required super.child,
    required RemoteController remoteController,
  }) : super(notifier: remoteController);

  static RemoteController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedRemoteNotifier>()?.notifier;
  }

  static RemoteController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'No RemoteController found in context');
    return controller!;
  }
}
