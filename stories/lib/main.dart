import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stories/firebase_options.dart';
import 'package:stories/landing.dart';
import 'package:stories/login.dart';
import 'package:stories/signup.dart';
import 'package:stories/my_app_lifecycle_observer.dart';
// import 'firebase_options.dart';
import 'user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register the User adapter
  Hive.registerAdapter(UserAdapter());
  await Hive.initFlutter();
  // Get the UID from the Hive box
  final userBox = await Hive.openBox<UserData>('userBox');
  final String uid =
      userBox.get('user')?.uid ?? ''; // Get the UID or use a default value

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MyApp(uid: uid));
  });
}

class MyApp extends StatelessWidget {
  final String uid;
  const MyApp({super.key, required this.uid});

  //  get the uid of the applicatio

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final lifecycleObserver = MyAppLifecycleObserver(uid);
    // Add the observer to the widget binding observer list
    WidgetsBinding.instance.addObserver(lifecycleObserver);

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
  void userExist() async {
    // Open the Hive box for user data
    final userBox = await Hive.openBox<UserData>('userBox');

    final String email = userBox.get('user')?.email ?? '';
    final String uid = userBox.get('user')?.uid ?? '';
    print('email is: $email and uid is: $uid');

    if (email.isNotEmpty && uid.isNotEmpty) {
      // Navigate to the landing page and pass email and uid as arguments
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Landing(email: email, uid: uid),
        ),
      );
    }

    // Close the Hive box
    await userBox.close();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    userExist();
  }

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
