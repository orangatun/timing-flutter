
import 'dart:async';
// import 'dart:html';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Timing',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Timers'),
      )
    );
  }
}


class MyAppState extends ChangeNotifier {
  List<TimerClock> timers = [];
  
  void addTimer(String name) {
    timers.add(TimerClock(name));
    notifyListeners();
  }

  void deleteTimer(TimerClock timer) {
    for(TimerClock t in timers) {
      if(t.hashCode == timer.hashCode) {
        timers.remove(t);
        break;
      }
    }
    notifyListeners();
  }

  void startTimer(TimerClock t) {
    t.startTimer();
    t.sysTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      t.running += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void stopTimer(TimerClock t) {
    t.stopTimer();
    t.sysTimer.cancel();
    notifyListeners();
  }

  void setTimerName(TimerClock t, String name) {
    t.name = name;
    notifyListeners();
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class Pair<T> {
  late final T a;
  late final T b;

  Pair(this.a, this.b);
}


class TimerClock {
  late DateTime start;
  late DateTime end;
  late Duration running;
  bool status = false;
  late String name;
  late List<Pair<DateTime>> past;
  late Timer sysTimer;

  TimerClock(this.name) {
    running = Duration.zero;
    past = [];
  }

  void set(start, end, status, name) {
    this.start = start;
    this.end = end;
    this.status = status;
    running = Duration.zero;
    past = [];
    this.name = name;
  }

  void setName(name) {
    this.name = name;
  }

  void startTimer() {
    status = true;
    start = DateTime.now();
  }

  void stopTimer() {
    status = false;
    end = DateTime.now();
    past.add(Pair<DateTime>(start, end));
  }
  
  void toggleTimer() {
    if(status == true) {
      stopTimer();
    } else {
      startTimer();
    }
  }
}


class TimerCard extends StatelessWidget {
  TimerCard({
    super.key,
    required this.t,
  });

  final TimerClock t;

  final numFormat = NumberFormat('00', 'en_US');

  @override
  Widget build(BuildContext context) {
  
  var appState = context.watch<MyAppState>();


  final theme = Theme.of(context);
  final timeStyle = theme.textTheme.displayMedium;//!.copyWith(color: theme.colorScheme.onSecondary);
  
    return Center(
      child: Card(
          child: InkWell(
            onLongPress: () => {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TimerDetailsView(timer: t)))
            },
            onTap: () => { 
                if(t.status == true) {
                  appState.stopTimer(t)
                } else {
                  appState.startTimer(t)
                }
            },
            child: SizedBox(
              height: 120,
              width: 180,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${numFormat.format(t.running.inMinutes)}:${numFormat.format(t.running.inSeconds%60)}',
                        style: timeStyle
                        ),
                    ),
                      Text(t.name),
                  ],
                ),
              ),
              ),
          ),
      ),
    );
  }
}


class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    var appState = context.watch<MyAppState>();

    var timersCount = appState.timers.length;

    if(appState.timers.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                addTimerModal(context, appState);
              },
              icon: const Icon(Icons.add_alarm_outlined))
          ],
        ),
        body: const Center(
          
          child: Text('No timers yet'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            onPressed: () {
                addTimerModal(context, appState);
              },
            icon: const Icon(Icons.add_alarm_outlined))
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget> [
            const Text(
              'Number of timers:',
            ),
            Text(
              '$timersCount'
            ),  
            Expanded(
              child: ListView(
                  children: <Widget>[
                    for(final t in appState.timers) 
                      TimerCard(t: t),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addTimerModal(BuildContext context, MyAppState appState) {

    final nameController = TextEditingController();

    final actionButtonTextStyle = Theme.of(context).textTheme.titleMedium;
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Column(
          children: [
            AppBar(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              title: const Text('Add Timer'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        
              leadingWidth: 100,
              leading: TextButton(
                child: Text('Cancel', style: actionButtonTextStyle),

                onPressed: () => Navigator.pop(context),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => {
                    // TO-DO: Text validation
                    appState.addTimer(nameController.text),
                    Navigator.pop(context),
                  },
                  child: Text('Done', style: actionButtonTextStyle),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 0.0),
              child: Column(
              children: <Widget>[
                TextFormField(
                  autocorrect: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Timer Name'
                  ),
                  controller: nameController,
                )
              ],
              ),
            ),
          ],
        );
      }
    );
  }
}


class TimerDetailsView extends StatelessWidget {

  const TimerDetailsView({super .key, required this.timer});

  final TimerClock timer;

  @override
  Widget build(BuildContext context) {

    var appState = context.watch<MyAppState>();

    final nameController = TextEditingController();
    nameController.text = timer.name;

    final actionButtonTextStyle = Theme.of(context).textTheme.titleMedium;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(timer.name),
        actions: <Widget>[
          TextButton(
            onPressed: () => {
              // TO-DO: Text validation
              appState.setTimerName(timer, nameController.text),
              Navigator.pop(context),
            },
            child: Text('Done', style: actionButtonTextStyle),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 8.0),
          child: Column(
        
            children: [
              SizedBox(
                child: TextFormField(
                  autocorrect: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Timer Name'
                  ),
                  controller: nameController,
                  
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top:20.0),
                child: FilledButton(
                  onPressed: () => {
                    appState.deleteTimer(timer),
                    Navigator.pop(context)
                  },
                  child: const Text('Delete'),
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
}