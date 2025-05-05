import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserInfoTile extends StatelessWidget {
  final User user;

  const UserInfoTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(user.photoURL ?? '')),
      title: Text(user.displayName ?? ''),
      subtitle: Text(user.email ?? ''),
    );
  }
}
