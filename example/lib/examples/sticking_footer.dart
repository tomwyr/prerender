import 'package:flutter/material.dart';
import 'package:prerender/prerender.dart';

class StickingFooterExample extends StatefulWidget {
  const StickingFooterExample({super.key});

  @override
  State<StickingFooterExample> createState() => _StickingFooterExampleState();
}

class _StickingFooterExampleState extends State<StickingFooterExample> {
  var itemCount = 1;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Prerender(
        target: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            content(),
            const Footer(),
          ],
        ),
        builder: (context, childSize, child) {
          if (childSize.height > constraints.maxHeight) {
            return SingleChildScrollView(child: child);
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                content(),
                const Spacer(),
                const Footer(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget content() {
    return ItemList(
      itemCount: itemCount,
      onAddItem: () {
        setState(() => itemCount++);
      },
      onRemoveItem: () {
        if (itemCount > 0) {
          setState(() => itemCount--);
        }
      },
    );
  }
}

class ItemList extends StatelessWidget {
  const ItemList({
    super.key,
    required this.itemCount,
    this.onAddItem,
    this.onRemoveItem,
  });

  final int itemCount;
  final VoidCallback? onAddItem;
  final VoidCallback? onRemoveItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ItemControl(
              icon: Icons.exposure_neg_1,
              onPressed: onRemoveItem,
            ),
            ItemControl(
              icon: Icons.exposure_plus_1,
              onPressed: onAddItem,
            ),
          ],
        ),
        ...Iterable.generate(
          itemCount,
          (index) => const Padding(
            padding: EdgeInsets.all(8),
            child: FlutterLogo(size: 48),
          ),
        ),
      ],
    );
  }
}

class ItemControl extends StatelessWidget {
  const ItemControl({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: OutlinedButton(
        onPressed: () {},
        child: const Text('Submit'),
      ),
    );
  }
}
