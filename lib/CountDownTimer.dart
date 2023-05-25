// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';

class KineticTrainerCountDownTimer extends StatefulWidget {

  const KineticTrainerCountDownTimer({
    Key? key,
    required this.startTime,
  }) : super(key: key);

  final int startTime;

  @override
  KineticTrainerCountDownTimerState createState() => KineticTrainerCountDownTimerState();
}

class KineticTrainerCountDownTimerState extends State<KineticTrainerCountDownTimer> {
  
  StreamSubscription<int>? _timer;

  int timeOnPause = 0;
  int lapsedTime = 0;
  int startTime = 0;
  List<int> exerciseTimes = [];

  @override
  void initState() {
    super.initState();

    lapsedTime = widget.startTime;

    setupForRun(
      startTime: widget.startTime,
    );

    start();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(lapsedTime.toString()),
            Text(
              'time'.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 8,
              )
            ),
          ],
        ),
      ),
    );
  }

  void setupForRun({int startTime = 0}) {
    setState(() {
      this.startTime = startTime;
    });
  }

  void stop() {
    _timer?.cancel();
  }

  void pause() {
    _timer?.pause();
  }

  void resume() {
    _timer?.resume();
  }

  void start() {
    stop();

    if (isPaused()) {
      resume();
    }

    _timer = _lapse(time: startTime).listen((elapsed) {
      if (mounted) {
        setState(() {
          lapsedTime = elapsed;

          if (lapsedTime == 0) {
            stop();
          }
        });
      }
    });
  }

  Stream<int> _lapse({int time = -1}) {
    return Stream.periodic(const Duration(seconds: 1), (lapse) {
      return time - lapse - 1;
    });
  }

  bool isPaused() {
    if (_timer != null) {
      return _timer!.isPaused;
    }

    return false;
  }

  bool isInLastExercise() {
    return exerciseTimes.last == lapsedTime;
  }
}
