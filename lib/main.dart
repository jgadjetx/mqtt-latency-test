import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqttest/MQTTClientManager.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  
  var rng = Random();
  late MQTTClientManager mqttClientManager;
  final String pubTopic = "test/counter";
  int startTime = 10000;
  int lapsedTime = 0;
  bool hasAlreadyStarted = false;

  String state = "stop";
  StreamSubscription<int>? _timer;


  @override
  void initState() {
    super.initState();

    var randomNum = rng.nextInt(100);
    mqttClientManager = MQTTClientManager(randomNum);
    setupMqttClient();

    mqttClientManager.getMessagesStream()!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {

      final recMess = c![0].payload as MqttPublishMessage;
      final state = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      setState(() {
        print("STATE IS::::::$state");
      });

      if(state == "start"){
        start();
        hasAlreadyStarted = true;
        setState(() {
          state == "start";
        });
      }
      else if(state == "stop"){

        setState(() {
          state == "stop";
        });

        if(hasAlreadyStarted){
          pause();
          
        }else{
          resume();
        }
        
      }
      else if(state == "restart"){
        
        startTime = 10000;

        _timer = _lapse(time: startTime).listen((elapsed) {
          setState(() {
            lapsedTime = elapsed;

            if (lapsedTime == 0) {
              stop();
            }
          });
          
        });

        mqttClientManager.publishMessage(pubTopic,"start");
        setState(() {
          state == "start";
        });
      }

    
    });

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Timer',
              style: TextStyle(
                fontSize: 20
              ),
            ),
             Text(
              "$lapsedTime",
              style: TextStyle(
                fontSize: 20
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                state == "stop" ?
                ElevatedButton(
                  onPressed: (){
          
                    setState(() { 
                      state = "start";
                    });         
                    
                    mqttClientManager.publishMessage(pubTopic,"$state");                  
                    
                  },
                  child: Text("Start"),
                ):
                ElevatedButton(
                  onPressed: (){

                    setState(() {
                      state = "stop";              
                    });;
                    
                    mqttClientManager.publishMessage(pubTopic,"$state");
                                    
                  },
                  child: Text("Pause"),
                ),
                ElevatedButton(
                  onPressed: (){
                    stop();

                    setState(() {
                      state = "restart";
                    });

                    mqttClientManager.publishMessage(pubTopic,"$state");
               
                  },
                  
                  child: Text("Restart"),
                ),
              ],
            )
            
          ],
        ),
      )
    );
  }

  Future<void> setupMqttClient() async {
    await mqttClientManager.connect();
    mqttClientManager.subscribe(pubTopic);
  }


  Stream<int> _lapse({int time = -1}) {
    return Stream.periodic(const Duration(seconds: 1), (lapse) {
      return time - lapse - 1;
    });
  }


  @override
  void dispose() {
    mqttClientManager.disconnect();
    super.dispose();
  }

  void stop() {
    _timer?.cancel();
  }

  void pause() {
    _timer?.pause();
  }

  bool isPaused() {
    if (_timer != null) {
      return _timer!.isPaused;
    }

    return false;
  }

  void resume() {
    _timer?.resume();
  }

  void start() {
    stop();

    _timer = _lapse(time: startTime).listen((elapsed) {

      setState(() {
        lapsedTime = elapsed;

        if (lapsedTime == 0) {
          stop();
        }
      });
      
    });
  }


}
