import 'dart:math';

import 'package:flutter/material.dart';
import 'package:prerender/prerender.dart';

class ExpandingTextExample extends StatelessWidget {
  const ExpandingTextExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        itemCount: messages.length,
        itemBuilder: (context, index) => AdaptingMessageTile(
          message: messages[index],
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
      ),
    );
  }
}

class AdaptingMessageTile extends StatelessWidget {
  const AdaptingMessageTile({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MessageTileCard(
      child: LayoutBuilder(
        builder: (context, constraints) => Prerender(
          target: SingleLineMessage(message: message),
          builder: (context, childSize, child) => MessageTile(
            message: message,
            expandable: childSize.width > constraints.maxWidth,
          ),
        ),
      ),
    );
  }
}

class SingleLineMessage extends StatelessWidget {
  const SingleLineMessage({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.short_text),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(message),
          ),
        ],
      ),
    );
  }
}

class MessageTile extends StatefulWidget {
  const MessageTile({
    super.key,
    required this.message,
    required this.expandable,
  });

  final String message;
  final bool expandable;

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  var expanded = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.short_text),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              widget.message,
              maxLines: expanded ? 999 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (widget.expandable) ...[
          const SizedBox(width: 12),
          ExpandButton(
            expanded: expanded,
            onToggle: (value) {
              setState(() {
                expanded = value;
              });
            },
          ),
        ],
      ],
    );
  }
}

class MessageTileCard extends StatelessWidget {
  const MessageTileCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        shadows: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ExpandButton extends StatelessWidget {
  const ExpandButton({
    super.key,
    required this.expanded,
    required this.onToggle,
  });

  final bool expanded;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: expanded ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 200),
      builder: (context, value, child) => IconButton(
        onPressed: () => onToggle(!expanded),
        icon: Transform.rotate(
          angle: -pi * value,
          child: const Icon(Icons.expand_more),
        ),
      ),
    );
  }
}

List<String> get messages => [
      'A single-line message',
      'A multi-line message that certainly will break into the next line making the text not fit into a single-line layout',
      'An even longer message that will span across multiple lines. This message is intended to be so lengthy that it continues on and on, describing various hypothetical scenarios, detailing verbose explanations, and providing an exhaustive example of how text can be extended indefinitely without any apparent end in sight, illustrating the concept of a message that is excessively long for the purpose of testing layout constraints.'
    ];
