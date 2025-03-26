// import 'package:flutter/material.dart';
// import 'main_page.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: const Text('Healthy Elderly'),
//       //   backgroundColor: Theme.of(context).colorScheme.primary,
//       // ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // App Name in Logo-like Style
//             Text(
//               'Healthy Elderly',
//               style: TextStyle(
//                 fontFamily: 'TanMonCheri', // Use the custom font for the logo
//                 fontSize: 42,
//                 fontWeight: FontWeight.bold,
//                 color: const Color(0xFF4E614D), // Primary color
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Welcome Message
//             const Text(
//               'Welcome to Healthy Elderly!',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF4E614D), // Primary color
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Your personalized nutrition guide for elders.',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Color(0xFFBCC8C8), // Accent color
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 32),
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to the Dashboard Page
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const MainPage()),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFA6CBBC), // Secondary color
//                 foregroundColor: Colors.white,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: const Text('Get Started'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }