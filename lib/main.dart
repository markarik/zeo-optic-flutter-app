import 'package:ze_optic_tech/features/map/google_map.dart';
import 'package:ze_optic_tech/features/users/users_list.dart';
import 'package:ze_optic_tech/imports.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase Auth',
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthScreenPage(),
        '/users': (context) => const UsersListScreen(),
        '/maps': (context) => UserCurrentLocation(
            userId: ModalRoute.of(context)?.settings.arguments as String),
      },
    );
  }
}

class AuthScreenPage extends StatelessWidget {
  const AuthScreenPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login & Signup'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Login'),
              Tab(text: 'Signup'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LoginCard(),
            SignupCard(),
          ],
        ),
      ),
    );
  }
}
