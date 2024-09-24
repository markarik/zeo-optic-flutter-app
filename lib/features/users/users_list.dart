import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ze_optic_tech/features/auth/repositories/auth_repo.dart';

class User {
  final String id;
  final String email;
  final String? displayName;

  User({required this.id, required this.email, this.displayName});

  factory User.fromRTDB(String key, Map<dynamic, dynamic> data) {
    return User(
      id: key,
      email: data['email'] ?? '',
      displayName: data['displayName'],
    );
  }
}

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  UsersListScreenState createState() => UsersListScreenState();
}

class UsersListScreenState extends State<UsersListScreen> {
  final AuthRepository _auth = AuthRepository();

  Stream<List<User>> getUsersStream() {
    return FirebaseDatabase.instance.ref().child('users').onValue.map((event) {
      final Map<dynamic, dynamic>? usersMap = event.snapshot.value as Map?;
      if (usersMap == null) return [];

      return usersMap.entries.map((entry) {
        return User.fromRTDB(entry.key, entry.value);
      }).toList();
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: StreamBuilder<List<User>>(
        stream: getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final user = snapshot.data![index];
              final userLoggedIn = _auth.currentUser;

              return user.id == userLoggedIn!.uid
                  ? const SizedBox.shrink()
                  : ListTile(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/maps',
                          arguments: user.id,
                        );
                      },
                      title: Text(user.email),
                      subtitle: Text(user.id),
                    );
            },
          );
        },
      ),
    );
  }
}
