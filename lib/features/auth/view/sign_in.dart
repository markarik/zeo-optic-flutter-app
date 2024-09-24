import 'dart:developer';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:ze_optic_tech/imports.dart';

class LoginCard extends StatefulWidget {
  const LoginCard({super.key});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final AuthRepository _auth = AuthRepository();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges.listen((User? user) {
      if (user != null) {
        Navigator.of(context).pushReplacementNamed('/users');
      }
    });
  }

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _auth.signIn(_emailController.text, _passwordController.text);
          Fluttertoast.showToast(
              msg: "Sign In Success",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);


        Navigator.of(context).pushReplacementNamed('/users');
      } catch (e) {
        log("Error signing in ,$e");
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AuthFormWidget(
            emailController: _emailController,
            passwordController: _passwordController,
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const LinearProgressIndicator()
              : ElevatedButton(
                  onPressed: () {
                    _signIn();
                  },
                  child: const Text('Signin'),
                ),
        ],
      ),
    );
  }
}
