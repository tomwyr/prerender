library prerender;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Builder function which is called after measuring [child] with result of
/// that operation passed as [childSize]. Widget returned from this function
/// is the actual widget that will be then rendered by [Prerender].
typedef PrerenderBuilder = Widget Function(
  BuildContext context,
  Size childSize,
  Widget child,
);

/// A widget that builds its content depending on intrinsic size of [target].
///
/// After measuring [target] during layout phase, [builder] is called with the
/// measured size to build a widget that is then used to replace [target] as
/// descendant of this widget.
///
/// [axis] can be used to control which intrinsic dimensions of [target] will be
/// measured:
/// - `null` (default) - both width and height
/// - `Axis.horizontal` - width only
/// - `Axis.vertical` - height only
/// 
/// Restricting measurement to only one axis can be useful if intrinsic
/// dimension of the other one cannot be calculated. In that case, skipped axis
/// will be replaced by maximum value(s) allowed by parent's constraints.
class Prerender extends RenderObjectWidget with _SingleChildRenderObjectWidget {
  const Prerender({
    super.key,
    required this.target,
    this.axis,
    required this.builder,
  });

  /// The widget to be measured.
  final Widget target;

  /// The axis along which to measure the widget.
  final Axis? axis;

  /// The builder function to create the final widget using the measured size.
  final PrerenderBuilder builder;

  @override
  RenderObjectElement createElement() => PrerenderElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) => RenderPrerender(axis: axis);

  @override
  void updateRenderObject(BuildContext context, RenderPrerender renderObject) =>
      renderObject..axis = axis;

  @override
  Widget get _child => target;
}

/// Element for [Prerender] widget which injects layout callback to
/// corresponding render object and marks when it needs to be rebuilt in order
/// to invoke that callback. This allows [Prerender] to manipulate
/// element's child widget during layout, which is normally impossible to do
/// from within a render object.
///
/// When render object calls the injected layout callback, newly calculated
/// size is passed to [Prerender.builder] to create a widget that will
/// replace initial child. The replacement and other [child] manipulations are
/// handled by [_SingleChildRenderObjectElement].
///
/// Because content of this element depends on layout of its descendant, it
/// does not support computing dry layout and intrinsic dimensions.
///
/// The result of [Prerender.builder] call is also wrapped in
/// [_PrerenderChild] that assures that the resulting child's state won't be
/// recreated between builds.
/// This would otherwise happen because the element's initial child is widget
/// that is only used for measurements and gets discarded after that. Because
/// the initial and the final child types are likely to be different, Flutter
/// would treat those child updates as if the descendant widget has changed,
/// even though all the operations take place during a single build and layout
/// process.
class PrerenderElement extends RenderObjectElement
    with _SingleChildRenderObjectElement, _ElementLayoutError {
  PrerenderElement(Prerender super.widget);

  final _builderChildKey = GlobalKey();

  @override
  Prerender get widget => super.widget as Prerender;

  @override
  RenderPrerender get renderObject => super.renderObject as RenderPrerender;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    renderObject.updateBuilderCallback(_buildAndReplaceChild);
  }

  @override
  void update(Prerender newWidget) {
    super.update(newWidget);
    renderObject.markNeedsBuild();
  }

  @override
  void performRebuild() {
    renderObject.markNeedsBuild();
    super.performRebuild();
  }

  void _buildAndReplaceChild(BoxConstraints constraints) {
    owner!.buildScope(this, () {
      Widget built;
      try {
        final childSize = renderObject._childSize;
        built = _PrerenderChild(
          key: _builderChildKey,
          child: widget.builder(this, childSize, widget.target),
        );
      } catch (e, stack) {
        built = buildError(e, stack);
      }
      try {
        child = updateChild(child, built, null);
      } catch (e, stack) {
        built = buildError(e, stack);
        child = updateChild(null, built, slot);
      }
    });
  }
}

/// Render object for [Prerender] widget which computes size of its
/// child during layout and invokes injected layout callback in order to
/// build new child depending on the calculated size. After that, the newly
/// created widget is laid out and painted.
class RenderPrerender extends RenderProxyBox with _ComputeLayoutError {
  RenderPrerender({
    required this.axis,
  });

  Axis? axis;

  late LayoutCallback<BoxConstraints> _builderCallback;

  var _needsBuild = true;
  var _childSize = Size.zero;

  void updateBuilderCallback(LayoutCallback<BoxConstraints> callback) {
    _builderCallback = callback;
    markNeedsLayout();
  }

  void markNeedsBuild() {
    if (!_needsBuild) {
      _needsBuild = true;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    if (_needsBuild) {
      _needsBuild = false;
      _childSize = _computeChildSize();
      invokeLayoutCallback(_builderCallback);
    }

    child!.layout(constraints, parentUsesSize: true);
    size = constraints.constrain(child!.size);
  }

  Size _computeChildSize() => Size(
        axis != Axis.vertical
            ? child!.computeMaxIntrinsicWidth(constraints.maxHeight)
            : constraints.maxWidth,
        axis != Axis.horizontal
            ? child!.computeMaxIntrinsicHeight(constraints.maxWidth)
            : constraints.maxHeight,
      );
}

/// Helper widget that pairs [Prerender.builder] result widget with a
/// global key in order to preserve resulting widget's state when it is
/// temporarily removed from element tree.
class _PrerenderChild extends StatelessWidget {
  const _PrerenderChild({
    required GlobalKey key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Helper mixin that must be mixed-in to any widget that wants its element to
/// be [_SingleChildRenderObjectElement].
mixin _SingleChildRenderObjectWidget on RenderObjectWidget {
  Widget get _child;
}

/// Helper mixin that mimics the behavior of [SingleChildRenderObjectElement]
/// but also exposes its [child].
mixin _SingleChildRenderObjectElement on RenderObjectElement {
  @override
  _SingleChildRenderObjectWidget get widget => super.widget as _SingleChildRenderObjectWidget;

  Element? child;

  @override
  void visitChildren(ElementVisitor visitor) {
    if (child != null) visitor(child!);
  }

  @override
  void forgetChild(Element child) {
    assert(child == this.child);
    this.child = null;
    super.forgetChild(child);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    child = updateChild(child, widget._child, null);
  }

  @override
  void update(RenderObjectWidget newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    child = updateChild(child, widget._child, null);
  }

  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {
    final renderObject = this.renderObject as RenderObjectWithChildMixin<RenderObject>;
    assert(slot == null);
    assert(renderObject.debugValidateChild(child));
    renderObject.child = child;
    assert(renderObject == this.renderObject);
  }

  @override
  void moveRenderObjectChild(RenderObject child, Object? oldSlot, Object? newSlot) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    final renderObject = this.renderObject as RenderObjectWithChildMixin<RenderObject>;
    assert(slot == null);
    assert(renderObject.child == child);
    renderObject.child = null;
    assert(renderObject == this.renderObject);
  }
}

// Helper mixin that builds and reports error that occurred during building
// widget by an element.
mixin _ElementLayoutError on Element {
  Widget buildError(Object exception, StackTrace stack) => ErrorWidget.builder(
        _debugReportException(
          ErrorDescription('building $widget'),
          exception,
          stack,
          informationCollector: () sync* {
            yield DiagnosticsDebugCreator(DebugCreator(this));
          },
        ),
      );

  FlutterErrorDetails _debugReportException(
    DiagnosticsNode context,
    Object exception,
    StackTrace stack, {
    InformationCollector? informationCollector,
  }) {
    final FlutterErrorDetails details = FlutterErrorDetails(
      exception: exception,
      stack: stack,
      library: 'widgets library',
      context: context,
      informationCollector: informationCollector,
    );
    FlutterError.reportError(details);
    return details;
  }
}

/// Helper mixin that adds layout assertions to a render box which does not
/// support dry layout and intrinsic dimensions.
mixin _ComputeLayoutError on RenderBox {
  @override
  double computeMinIntrinsicWidth(double height) {
    assert(_debugCannotComputeIntrinsics());
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    assert(_debugCannotComputeIntrinsics());
    return 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    assert(_debugCannotComputeIntrinsics());
    return 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    assert(_debugCannotComputeIntrinsics());
    return 0.0;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    assert(debugCannotComputeDryLayout(
      error: _getLayoutError(operation: 'computing dry layout'),
    ));
    return Size.zero;
  }

  bool _debugCannotComputeIntrinsics() {
    assert(() {
      if (!RenderObject.debugCheckingIntrinsics) {
        throw _getLayoutError(operation: 'computing intrinsic dimensions');
      }
      return true;
    }());
    return true;
  }

  FlutterError _getLayoutError({required String operation}) {
    final objectType = objectRuntimeType(this, 'RenderBox');

    return FlutterError('$objectType does not support $operation.');
  }
}
