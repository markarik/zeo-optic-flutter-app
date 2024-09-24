import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ze_optic_tech/imports.dart';

class SignupCard extends StatefulWidget {
  const SignupCard({super.key});

  @override
  State<SignupCard> createState() => _SignupCardState();
}

class _SignupCardState extends State<SignupCard> {
  final AuthRepository _auth = AuthRepository();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final FirebaseDatabase database = FirebaseDatabase.instance;

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        User? user =
            await _auth.signUp(_emailController.text, _passwordController.text);

        if (user != null) {
          DatabaseReference usersRef = database.ref().child('users');

          await usersRef.child(user.uid).set({
            'uid': user.uid,
            'displayName': user.displayName,
            'email': user.email,
            'createdAt': DateTime.now().toIso8601String(),
          });

          Fluttertoast.showToast(
              msg: "Sign Up Success",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);

          Navigator.of(context).pushReplacementNamed('/users');
        }
      } catch (e) {
        log("Error signing up ,$e");
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
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
                      _signUp();
                    },
                    child: const Text('Signup'),
                  ),
          ],
        ),
      ),
    );
  }
}
