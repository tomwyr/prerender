import 'package:example/examples/responsive_sheet.dart';
import 'package:example/examples/expanding_text.dart';
import 'package:example/examples/sticking_footer.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExamplesApp());
}

class ExamplesApp extends StatefulWidget {
  const ExamplesApp({super.key});

  @override
  State<ExamplesApp> createState() => _ExamplesAppState();
}

class _ExamplesAppState extends State<ExamplesApp> {
  final items = [
    ('Expanding Text', const ExpandingTextExample()),
    ('Sticking Footer', const StickingFooterExample()),
    ('Responsive Sheet', const ResponsiveSheetExample()),
  ];

  late var currentItem = items.last;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(currentItem.$1),
        ),
        drawer: Drawer(
          child: Column(
            children: [
              for (var (item) in items)
                DrawerItem(
                  title: item.$1,
                  onSelect: () {
                    setState(() => currentItem = item);
                  },
                ),
            ],
          ),
        ),
        body: currentItem.$2,
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    super.key,
    required this.title,
    required this.onSelect,
  });

  final String title;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: () {
        onSelect();
        Scaffold.of(context).closeDrawer();
      },
    );
  }
}
