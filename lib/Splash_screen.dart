// import 'dart:async';

// import 'package:flutter/material.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();

//     Timer(Duration(seconds: 3), () {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (context) => (HomePage())));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.orange,
//         body: Center(
//             child: Container(
//           child: Text(
//             'This is the Splash Screen',
//             style: TextStyle(
//                 fontFamily: AutofillHints.name,
//                 fontSize: 60,
//                 fontWeight: FontWeight.w800),
//           ),
//         )));
//   }
// }