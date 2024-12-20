# Prerender

The `Prerender` widget allows building widget trees where one widget's layout depends on another's size.

Flutter's rendering pipeline provides parent size information but doesn't allow computing other widgets' sizes inside the `build` method. The `Prerender` package solves this by measuring a widget and deferring the final build until its dimensions are known, all within a single frame.

## Getting Started

The `Prerender` widget resolves its layout in a few steps to access the target's size:

1. The render object lays out the `target` as if it were the sole child of `Prerender`, allowing the target to fill the parent.
2. The render object stores the computed dimensions and calls the `builder` function, passing it the target's resolved size.
3. The `builder` callback then decides on the final shape of the child widget tree using (or not) the previously computed layout.

Rebuilding the tree with a different target widget will cause the `builder` to be called again with an updated target size.

> [!NOTE]
> Due to the nature of the problem that `Prerender` attempts to solve, it requires computing a speculative layout of the measured widget. This implies both the limitations of running speculative layouts and the performance considerations of additional layout computations during each build.

## Usage

Add the dependency to your `pubspec.yaml`:

```yaml
prerender: ^1.0.0
```

Wrap the widget tree that depends on some widget's layout:

```dart
Prerender(
  // Provide the widget that you want to measure:
  target: ...,
  // Build the actual child using the computed layout:
  builder: (context, childSize, child) {
    ...
  },
)
```

For example, prefix the title with an avatar only if there's enough horizontal space:

```dart
Prerender(
  target: Title(),
  builder: (context, childSize, child) {
    return Row(
      children: [
        if (childSize.width < 200) Avatar(),
        child,
      ],
    );
  },
)
```

## Single Frame Rendering

In addition to having more fine-grained control over building widgets, another key benefit of using `Prerender` is accessing and using other widgets' dimensions information within a single frame:

```dart
// Using GlobalKey (imperative)
final titleKey = GlobalKey();

Widget build(BuildContext context) {
  var titleSize = Size.zero;
  final renderObject = titleKey.currentContext?.findRenderObject();
  if (renderObject != null) {
    titleSize = (renderObject as RenderBox).size;
  }

  return Row(
    children: [
      // Size always being one frame behind.
      if (titleSize.width < 200) Avatar(),
      Title(key: titleKey),
    ],
  );
}

// Using Prerender (declarative)
Widget build(BuildContext context) {
  return Prerender(
    target: Title(),
    builder: (context, childSize, child) {
      return Row(
        children: [
          if (childSize.width < 200) Avatar(),
          child,
        ],
      );
    },
  );
}
```

## Examples

- **Expanding Text**: Display an expand button only for text widgets whose width is greater than the available horizontal area.

https://github.com/user-attachments/assets/0b6f3838-b4bb-4065-a84c-2883805e19c3

- **Sticking Footer**: Stick the footer button to the bottom edge of the screen if the content is smaller than the available area.

https://github.com/user-attachments/assets/27736726-55ff-4be1-a022-d1347d59d667

- **Responsive Sheet**: Align the bottom sheet's height in the collapsed state with the vertical size of the body to prevent displaying a blank area.

https://github.com/user-attachments/assets/30b8c8ca-a0dd-4e83-8fdd-ff7e072d47c7
