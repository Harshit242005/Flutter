import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stories/login.dart';
import 'package:stories/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Register the User adapter
  Hive.registerAdapter(UserAdapter());
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Stories',
              style: TextStyle(
                  fontFamily: 'ReadexPro',
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 25,
            ),
            Column(
              children: <Widget>[
                ElevatedButton(
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                        minimumSize:
                            MaterialStateProperty.all(const Size(200, 50)),
                        elevation: MaterialStateProperty.all(0.0),
                        side: MaterialStateProperty.all(
                            const BorderSide(color: Colors.black, width: 0.5)),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white)),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Signup()));
                    },
                    child: const Text(
                      'Signup',
                      style: TextStyle(
                          fontFamily: 'Readexpro',
                          fontSize: 18,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    )),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                        minimumSize:
                            MaterialStateProperty.all(const Size(200, 50)),
                        elevation: MaterialStateProperty.all(0.0),
                        side: MaterialStateProperty.all(
                            const BorderSide(color: Colors.black, width: 0.5)),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white)),
                    onPressed: () {
                      // navigate to the login screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Login(),
                        ),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                          fontFamily: 'Readexpro',
                          letterSpacing: 1.5,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
