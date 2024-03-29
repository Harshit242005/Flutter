import 'package:CodeUp/MonthDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:window_manager/window_manager.dart';

void main() async {
  //needed to ensure binding was initialized
  WidgetsFlutterBinding.ensureInitialized();

  await WindowManager.instance.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitle('CodeUp');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner:
            false, // Set this to false to remove the debug banner
        title: 'CodeUp',
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text(
              'CodeUp',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'ReadexPro'),
            ),
            elevation: 1.0,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [ButtonGrid()],
              ),
            ),
          ),
        ));
  }
}

class ButtonGrid extends StatelessWidget {
  final List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16.0,
      runSpacing: 16.0,
      children: List.generate(
        monthNames.length,
        (index) => MonthButton(month: monthNames[index]),
      ),
    );
  }
}

class MonthButton extends StatelessWidget {
  final String month;

  const MonthButton({required this.month});

  // connecting with backend and calling the function for it
  Future<void> sendDataToServer(String month) async {
    final url = Uri.parse('http://localhost:3000/api/data/$month');

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        // Server responded successfully, handle the response if needed
        print('Data sent successfully for $month');
      } else {
        // Handle other status codes
        print('Failed to send data for $month: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error sending data for $month: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = 400.0; // Set your preferred button width
    double fontSize = screenWidth < buttonWidth ? 14.0 : 16.0;
    return Expanded(
      child: SizedBox(
        width: 250.0, // Set your preferred width4
        height: 50.0, // Set your preferred height
        child: ElevatedButton(
          onPressed: () {
            // Handle button press for the specific month
            // ignore: avoid_print
            print('Button pressed for $month');
            // calling the function to send the collection name
            sendDataToServer(month);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MonthDetailsPage(month: month),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyan.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  10.0), // Set your preferred border radius
            ),
          ),
          child: Text(
            month,
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'ReadexPro',
                fontWeight: FontWeight.w600,
                fontSize: fontSize),
          ),
        ),
      ),
    );
  }
}
