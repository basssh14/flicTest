import 'package:flutter/material.dart';

class Fake extends StatefulWidget {
  const Fake({Key? key}) : super(key: key);

  @override
  State<Fake> createState() => _FakeState();
}

class _FakeState extends State<Fake> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
