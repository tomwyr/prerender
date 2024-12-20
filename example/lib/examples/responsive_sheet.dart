import 'package:flutter/material.dart';
import 'package:prerender/prerender.dart';

class ResponsiveSheetExample extends StatelessWidget {
  const ResponsiveSheetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Prerender(
        target: const Content(),
        builder: (context, childSize, child) {
          const maxChildSize = 0.8;
          var minChildSize = 1 - childSize.height / constraints.maxHeight;
          minChildSize = minChildSize.clamp(0.2, maxChildSize);

          final bottomPadding = constraints.maxHeight * minChildSize;

          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: const Content(),
                ),
              ),
              DraggableScrollableSheet(
                initialChildSize: minChildSize,
                minChildSize: minChildSize,
                maxChildSize: maxChildSize,
                builder: (context, scrollController) =>
                    ItemList(scrollController: scrollController),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ItemList extends StatelessWidget {
  const ItemList({
    super.key,
    required this.scrollController,
  });

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ListView.builder(
        controller: scrollController,
        itemCount: 20,
        itemBuilder: (context, index) => ListTile(
          title: Text('Item $index'),
        ),
      ),
    );
  }
}

class Content extends StatelessWidget {
  const Content({super.key});

  String get bodyText => '''
Lorem dolore anim Lorem exercitation incididunt dolor mollit. Commodo dolore nisi sit sit. Eu consequat mollit velit qui enim occaecat. Fugiat occaecat consequat incididunt proident deserunt in reprehenderit. Non id magna et adipisicing duis dolore ex.

Eu id consectetur fugiat deserunt magna. Incididunt pariatur occaecat voluptate pariatur aliqua commodo ullamco adipisicing. Ex ad sit tempor dolore irure dolore cillum cillum nostrud laboris cillum veniam. Labore irure qui pariatur sunt deserunt nostrud ut et tempor eiusmod velit occaecat. Mollit pariatur veniam anim sit non dolor. Deserunt dolor do ea excepteur et labore occaecat et labore laborum esse culpa dolore labore. Mollit elit incididunt ad magna amet adipisicing laboris pariatur deserunt nulla.

Sint qui Lorem eu irure enim occaecat tempor aliquip eu. Veniam est ullamco ex reprehenderit culpa consequat eiusmod ipsum eiusmod aliqua. Officia sint et id qui.
'''
      .trim();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(bodyText),
    );
  }
}
