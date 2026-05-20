import 'package:flutter/material.dart';

class AuthSection extends StatelessWidget {
  const AuthSection({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // We strip away the card container completely.
    // We also filter out any Dividers that might have been added previously
    // for the old card style, so they don't awkwardly show up between fields.
    final fieldsOnly = children.where((w) => w is! Divider).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: fieldsOnly,
    );
  }
}
