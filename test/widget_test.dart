import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prerender/prerender.dart';

void main() {
  testWidgets('calls builder with correct child size', (tester) async {
    final targetSize = Completer<Size>();

    expectLater(targetSize.future, completion(const Size(100, 120)));

    final widget = Prerender(
      target: const SizedBox(width: 100, height: 120),
      builder: (context, childSize, child) {
        targetSize.complete(childSize);
        return Container();
      },
    );

    await tester.pumpWidget(widget);
  });

  testWidgets('passes target widget as child', (tester) async {
    const target = SizedBox(width: 100, height: 120);
    final builderChild = Completer<Widget>();

    expectLater(builderChild.future, completion(target));

    final widget = Prerender(
      target: target,
      builder: (context, childSize, child) {
        builderChild.complete(child);
        return Container();
      },
    );

    await tester.pumpWidget(widget);
  });

  testWidgets('finds target widget if it was returned from the builder', (tester) async {
    const target = SizedBox(width: 100, height: 120);

    final widget = Prerender(
      target: target,
      builder: (context, childSize, child) {
        return target;
      },
    );

    await tester.pumpWidget(widget);

    expect(find.byWidget(target), findsOneWidget);
  });

  testWidgets('does not find target widget if it was discarded from the builder', (tester) async {
    const target = SizedBox(width: 100, height: 120);

    final widget = Prerender(
      target: target,
      builder: (context, childSize, child) {
        return Container();
      },
    );

    await tester.pumpWidget(widget);

    expect(find.byWidget(target), findsNothing);
  });
}
