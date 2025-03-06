import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    if (Platform.isAndroid) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDIwfWtVftZxGlL8C2kcuhmykctxiKtC6c",
          appId: "1:666355265985:android:2872f64da7d46aee2a3f40",
          messagingSenderId: "666355265985",
          projectId: "tempandpasscode1",
          databaseURL: "https://tempandpasscode1-default-rtdb.asia-southeast1.firebasedatabase.app",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Embedded Project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Embedded Project',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100),
                    const Text(
                      'Welcome to Embedded Project\n(Temperature-Based Door Access System Using Firebase and Flutter)\nBy Group 2.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black45,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the HomeScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5, // Add shadow for better depth
                      ),
                      child: const Text(
                        'Proceed to Door Access',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String enteredPasscode = '';
  String passcodeStatus = 'Locked';
  bool isUnlocked = false;
  String feverStatus = '';

  double temperature = 38.0;
  int personCount = 1;
  int personLimit = 30;
  String doorStatus = 'Locked';
  String passcode = '1234'; // Default passcode (this will be updated from Firebase)

  late DatabaseReference _doorStatusRef;
  late DatabaseReference _passcodeRef;
  late DatabaseReference _personCountRef;
  late DatabaseReference _personLimitRef;
  late DatabaseReference _temperatureRef;

  @override
  void initState() {
    super.initState();

    // Initialize Firebase database references
    _doorStatusRef = FirebaseDatabase.instance.ref('doorStatus');
    _passcodeRef = FirebaseDatabase.instance.ref('passcode');
    _personCountRef = FirebaseDatabase.instance.ref('personCount');
    _personLimitRef = FirebaseDatabase.instance.ref('personLimit');
    _temperatureRef = FirebaseDatabase.instance.ref('temperature');

    // Set up real-time listeners
    setupListeners();
  }

  void setupListeners() {
    _doorStatusRef.onValue.listen((event) {
      setState(() {
        doorStatus = event.snapshot.value as String? ?? 'Locked';
      });
    });

    _passcodeRef.onValue.listen((event) {
      setState(() {
        passcode = event.snapshot.value?.toString() ?? '1234'; // Update passcode from Firebase
      });
    });

    _personCountRef.onValue.listen((event) {
      setState(() {
        personCount = event.snapshot.value as int? ?? 0;
      });
    });

    _personLimitRef.onValue.listen((event) {
      setState(() {
        personLimit = event.snapshot.value as int? ?? 30;
      });
    });

    _temperatureRef.onValue.listen((event) {
      setState(() {
        temperature = (event.snapshot.value as num?)?.toDouble() ?? 38.0;
      });
    });
  }

  @override
  void dispose() {
    // Clean up listeners
    _doorStatusRef.onDisconnect();
    _passcodeRef.onDisconnect();
    _personCountRef.onDisconnect();
    _personLimitRef.onDisconnect();
    _temperatureRef.onDisconnect();
    super.dispose();
  }

  void checkPasscode() async {
    // If person count exceeds the limit or the temperature is high, lock the door
    if (personCount >= personLimit) {
      setState(() {
        feverStatus = 'Person limit exceeded. Cannot unlock the door.';
        passcodeStatus = 'Locked';
        isUnlocked = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Person limit exceeded. Please wait for others to exit.'),
        ),
      );
    } else if (temperature >= 38) {
      setState(() {
        feverStatus = 'You have a fever. Cannot unlock the door.';
        passcodeStatus = 'Locked';
        isUnlocked = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Temperature too high. You cannot open the door.'),
        ),
      );
    } else if (enteredPasscode == passcode) {
      setState(() {
        passcodeStatus = 'Unlocked';
        isUnlocked = true;
        feverStatus = '';
      });

      // Update door status in Firebase to "Unlocked via passcode"
      _doorStatusRef.set('Unlocked via passcode');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The door has been unlocked using the passcode.'),
        ),
      );
    } else {
      setState(() {
        passcodeStatus = 'Locked';
        isUnlocked = false;
      });

      // Show incorrect passcode message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect passcode. Please try again.'),
        ),
      );
    }
  }

// Function to lock the door via the app and update the status in Firebase
  void lockDoorviaApp() {
    setState(() {
      passcodeStatus = 'Locked';
      isUnlocked = false;
      feverStatus = '';
    });

    _doorStatusRef.set('Locked via Application');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('The door has been locked successfully.'),
      ),
    );
  }

  Color getTemperatureColor(double temp) {
    if (temp >= 38) {
      return Colors.red;
    } else if (temp >= 31) {
      return Colors.yellow;
    } else {
      return Colors.white60;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Embedded Project',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Temperature Info Card
                  _buildInfoCard(
                    'Temperature',
                    '$temperature°C',
                    Colors.black,
                    getTemperatureColor(temperature),
                  ),
                  const SizedBox(height: 20),

                  // Person Count Info Card
                  _buildInfoCard(
                    'Person Count',
                    '$personCount',
                    Colors.black,
                    Colors.grey,
                  ),
                  const SizedBox(height: 20),

                  // Person Limit Info Card
                  _buildInfoCard(
                    'Person Limit',
                    '$personLimit',
                    Colors.black,
                    Colors.red,
                  ),
                  const SizedBox(height: 20),

                  // Door Status Info Card
                  _buildInfoCard(
                    'Door Status',
                    doorStatus,
                    Colors.black,
                    doorStatus == 'Unlocked' || doorStatus == 'Unlocked via passcode' ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 20),

                  if (feverStatus.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        feverStatus,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Enter passcode',
                        labelStyle: const TextStyle(color: Colors.white),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue.shade300),
                        ),
                      ),
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          enteredPasscode = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: checkPasscode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                        child: const Text(
                          'Unlock Door',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: lockDoorviaApp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                        child: const Text(
                          'Lock Door',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color titleColor, Color valueColor) {
    return Card(
      elevation: 5,
      color: Colors.white.withOpacity(0.7),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
