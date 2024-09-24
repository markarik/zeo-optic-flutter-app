import 'package:ze_optic_tech/imports.dart';

class AuthFormWidget extends StatefulWidget {
  const AuthFormWidget({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  State<AuthFormWidget> createState() => _AuthFormWidgetState();
}

class _AuthFormWidgetState extends State<AuthFormWidget> {
  bool _isShowPassword = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
              controller: widget.emailController,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _isShowPassword = !_isShowPassword);
                  },
                  icon: Icon(
                    !_isShowPassword ? Icons.hide_source : Icons.remove_red_eye,
                  ),
                ),
              ),
              obscureText: _isShowPassword,
              controller: widget.passwordController,
            ),
          ],
        ),
      ),
    );
  }
}
