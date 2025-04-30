// // import 'package:estudy_gpt/widgets/user_info_title.dart';
// // import 'package:flutter/material.dart';
// // import 'package:google_sign_in/google_sign_in.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'webview_bridge.dart';

// // class LoginPage extends StatefulWidget {
// //   const LoginPage({super.key});

// //   @override
// //   State<LoginPage> createState() => _LoginPageState();
// // }

// // class _LoginPageState extends State<LoginPage> {
// //   final GoogleSignIn _googleSignIn = GoogleSignIn();
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   User? _currentUser;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _auth.authStateChanges().listen((User? user) {
// //       setState(() {
// //         _currentUser = user;
// //       });

// //       if (user != null) {
// //         Navigator.push(
// //           context,
// //           MaterialPageRoute(builder: (context) => WebViewBridge(user: user)),
// //         );
// //       }
// //     });
// //   }

// //   Future<void> _handleSignIn() async {
// //     try {
// //       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
// //       final GoogleSignInAuthentication googleAuth =
// //           await googleUser!.authentication;

// //       final credential = GoogleAuthProvider.credential(
// //         accessToken: googleAuth.accessToken,
// //         idToken: googleAuth.idToken,
// //       );

// //       await _auth.signInWithCredential(credential);
// //     } catch (error) {
// //       debugPrint('Google Sign-In Error: $error');
// //     }
// //   }

// //   Future<void> _handleSignOut() async {
// //     await _auth.signOut();
// //     await _googleSignIn.signOut();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Firebase Auth Login')),
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             if (_currentUser != null)
// //               UserInfoTile(user: _currentUser!)
// //             else
// //               const Text('You are not signed in.'),
// //             ElevatedButton(
// //               onPressed: _currentUser != null ? _handleSignOut : _handleSignIn,
// //               child: Text(
// //                 _currentUser != null ? 'Sign Out' : 'Sign In with Google',
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:estudy_gpt/screens/main_screen.dart';
// import 'package:estudy_gpt/widgets/user_info_title.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   User? _currentUser;
//   bool _isInitialCheck = true;

//   @override
//   void initState() {
//     super.initState();

//     // 현재 사용자 확인 (앱 최초 실행 시)
//     _auth.authStateChanges().listen((User? user) {
//       setState(() {
//         _currentUser = user;
//       });

//       if (user != null) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => MainScreen(user: user)),
//           );
//         });
//       }

//       setState(() => _currentUser = user);
//     });
//   }

//   Future<void> _handleSignIn() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         // 사용자가 로그인 취소
//         return;
//       }
//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       await _auth.signInWithCredential(credential);
//     } catch (error) {
//       debugPrint('Google Sign-In Error: $error');
//       // 로그인 실패 시 아무 동작 없음(현재 화면 유지)
//     }
//   }

//   Future<void> _handleSignOut() async {
//     await _auth.signOut();
//     await _googleSignIn.signOut();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Firebase Auth Login')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (_currentUser != null)
//               UserInfoTile(user: _currentUser!)
//             else
//               const Text('You are not signed in.'),
//             ElevatedButton(
//               onPressed: _currentUser != null ? _handleSignOut : _handleSignIn,
//               child: Text(
//                 _currentUser != null ? 'Sign Out' : 'Sign In with Google',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
