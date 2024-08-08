import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import 'package:flutter/rendering.dart'; // For Timer

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  String humidity = '';
  String light = '';
  String soilMoisture = '';
  String temperature = '';
  int pumpControl = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch initial data
    timer = Timer.periodic(Duration(seconds: 3),
        (Timer t) => fetchData()); // Fetch new data every 3 seconds
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void fetchData() async {
    DataSnapshot snapshot = await databaseReference.get();

    setState(() {
      humidity = snapshot.child('humidity').value?.toString() ?? '';
      light = snapshot.child('light').value?.toString() ?? '';
      soilMoisture = snapshot.child('soilMoisture').value?.toString() ?? '';
      temperature = snapshot.child('temperature').value?.toString() ?? '';
      pumpControl = int.tryParse(
              snapshot.child('pumpControl').value?.toString() ?? '0') ??
          0;
    });
  }

  void togglePump() async {
    int newPumpControlValue = pumpControl == 0 ? 1 : 0;

    await databaseReference.child('pumpControl').set(newPumpControlValue);
    setState(() {
      pumpControl = newPumpControlValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent,
              Colors.purple,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Spacer(),
            const Align(
              child: Text(
                'Plant Irrigaion',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _containers(
                    'assets/temperature.jpg', '$temperature', 'Temprature'),
                _containers(
                    'assets/soil.jpeg', '$soilMoisture', 'Soil Moisture'),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _containers('assets/humidity.jpg', '$humidity', 'Humidity'),
                _containers('assets/sun.jpg', '$light', 'Light'),
              ],
            ),
            Spacer(),

            // buttons
            InkWell(
              onTap: togglePump,
              child: Container(
                alignment: Alignment.center,
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(150),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.blueAccent,
                        Colors.lightBlueAccent,
                      ],
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                    )),
                child: Text(
                  pumpControl == 1 ? 'Turn OFF' : 'Turn ON',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  // this is for container
  Widget _containers(String image, String text, String title) {
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      width: 150,
      margin: EdgeInsets.all(4),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 145,
            width: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image(
                image: AssetImage('$image'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$title:',
                style: TextStyle(fontSize: 14, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                text,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
