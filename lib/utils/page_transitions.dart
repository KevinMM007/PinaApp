import 'package:flutter/material.dart';

/// Transiciones personalizadas para navegación entre pantallas
class PageTransitions {
  
  /// Transición de deslizamiento desde la derecha (iOS style)
  static Route<T> slideFromRight<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Transición de deslizamiento desde abajo
  static Route<T> slideFromBottom<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Transición de desvanecimiento
  static Route<T> fade<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        var tween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return FadeTransition(
          opacity: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Transición de escala con desvanecimiento
  static Route<T> scaleAndFade<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;
        
        var scaleTween = Tween(begin: 0.8, end: 1.0).chain(
          CurveTween(curve: curve),
        );
        
        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  /// Transición de rotación y desvanecimiento
  static Route<T> rotateAndFade<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutBack;
        
        var rotationTween = Tween(begin: 0.1, end: 0.0).chain(
          CurveTween(curve: curve),
        );
        
        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeInOut),
        );

        return RotationTransition(
          turns: animation.drive(rotationTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  /// Transición de deslizamiento con escala
  static Route<T> slideWithScale<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 400),
    Offset slideDirection = const Offset(1.0, 0.0),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeOutCubic;
        
        var slideTween = Tween(begin: slideDirection, end: Offset.zero).chain(
          CurveTween(curve: curve),
        );
        
        var scaleTween = Tween(begin: 0.9, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(slideTween),
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            child: child,
          ),
        );
      },
    );
  }

  /// Transición de morphing (para elementos relacionados)
  static Route<T> morphing<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Animación principal
        var primaryAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
        );
        
        // Animación secundaria
        var secondaryAnimationCurved = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.3, 1.0, curve: Curves.easeInCubic),
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Stack(
              children: [
                // Página saliente con escala
                if (secondaryAnimation.value > 0)
                  Transform.scale(
                    scale: 1 - (secondaryAnimation.value * 0.1),
                    child: Opacity(
                      opacity: 1 - secondaryAnimation.value,
                      child: Container(), // Placeholder para la página anterior
                    ),
                  ),
                
                // Página entrante
                Transform.scale(
                  scale: primaryAnimation.value,
                  child: FadeTransition(
                    opacity: secondaryAnimationCurved,
                    child: child,
                  ),
                ),
              ],
            );
          },
          child: child,
        );
      },
    );
  }
}

/// Extensión para facilitar el uso de transiciones en Navigator
extension NavigatorTransitions on NavigatorState {
  
  /// Push con transición de deslizamiento desde la derecha
  Future<T?> pushSlideFromRight<T extends Object?>(Widget page) {
    return push(PageTransitions.slideFromRight<T>(page));
  }

  /// Push con transición de deslizamiento desde abajo
  Future<T?> pushSlideFromBottom<T extends Object?>(Widget page) {
    return push(PageTransitions.slideFromBottom<T>(page));
  }

  /// Push con transición de desvanecimiento
  Future<T?> pushFade<T extends Object?>(Widget page) {
    return push(PageTransitions.fade<T>(page));
  }

  /// Push con transición de escala y desvanecimiento
  Future<T?> pushScaleAndFade<T extends Object?>(Widget page) {
    return push(PageTransitions.scaleAndFade<T>(page));
  }

  /// Push con transición de rotación y desvanecimiento
  Future<T?> pushRotateAndFade<T extends Object?>(Widget page) {
    return push(PageTransitions.rotateAndFade<T>(page));
  }

  /// Push con transición de morphing
  Future<T?> pushMorphing<T extends Object?>(Widget page) {
    return push(PageTransitions.morphing<T>(page));
  }

  /// Push replacement con transición personalizada
  Future<T?> pushReplacementWithTransition<T extends Object?, TO extends Object?>(
    Widget page,
    Route<T> Function(Widget) transitionBuilder,
  ) {
    return pushReplacement(transitionBuilder(page));
  }
}

/// Widget para transiciones personalizadas dentro de la misma pantalla
class AnimatedSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration reverseDuration;
  final Widget Function(Widget, Animation<double>) transitionBuilder;

  const AnimatedSwitcher({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    Duration? reverseDuration,
    required this.transitionBuilder,
  }) : reverseDuration = reverseDuration ?? duration, super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      reverseDuration: reverseDuration,
      transitionBuilder: transitionBuilder,
      child: child,
    );
  }

  /// Constructor para transición de desvanecimiento
  AnimatedSwitcher.fade({
    Key? key,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Duration? reverseDuration,
  }) : this(
    key: key,
    child: child,
    duration: duration,
    reverseDuration: reverseDuration,
    transitionBuilder: (child, animation) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );

  /// Constructor para transición de deslizamiento
  AnimatedSwitcher.slide({
    Key? key,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Duration? reverseDuration,
    Offset slideDirection = const Offset(0.0, 1.0),
  }) : this(
    key: key,
    child: child,
    duration: duration,
    reverseDuration: reverseDuration,
    transitionBuilder: (child, animation) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: slideDirection,
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );

  /// Constructor para transición de escala
  AnimatedSwitcher.scale({
    Key? key,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Duration? reverseDuration,
  }) : this(
    key: key,
    child: child,
    duration: duration,
    reverseDuration: reverseDuration,
    transitionBuilder: (child, animation) {
      return ScaleTransition(
        scale: animation,
        child: child,
      );
    },
  );
}

/// Widget para animar cambios de contenido con Hero
class HeroTransition extends StatelessWidget {
  final String tag;
  final Widget child;
  final Duration duration;

  const HeroTransition({
    Key? key,
    required this.tag,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      transitionOnUserGestures: true,
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}
