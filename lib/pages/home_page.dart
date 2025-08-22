import 'package:chatify_app/providers/authentication_provider.dart';
import 'package:chatify_app/widgets/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RoundedButton(
          name: 'Logout',
          height: 50,
          width: 200,
          onPressed: () {
            Provider.of<AuthenticationProvider>(
              context,
              listen: false,
            ).logout();
          },
        ),
      ),
    );
  }
}
