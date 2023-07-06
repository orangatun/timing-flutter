

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
  // List<TimerClock> timers = List.empty(growable: true);
  List<TimerClock> timers = [];
  
  void timerStartStop(index) {

    // if(timers[index].status == true) {
    //   timers[index].stopTimer();
    // } else {
    //   timers[index].startTimer();
    // }
    print('Started/Stopped timer');
    // notifyListeners();
  }

  void addTimer() {
    timers.add(TimerClock());
    print('Added timer');
    notifyListeners();
  }
  //TO-DO: Add timer and Delete Timer functions
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

  TimerClock() {
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
    print('Started timer');
  }

  void stopTimer() {
    status = false;
    end = DateTime.now();
    print('Running before: $running');

    running = running + end.difference(start);
    past.add(Pair<DateTime>(start, end));
    print('Stopped timer $running');
  }
  
  void toggleTimer() {
    if(status == true) {
      stopTimer();
    } else {
      startTimer();
    }
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
                appState.addTimer();
                print('Timer added');
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
              appState.addTimer();
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
                      TimerView(t: t),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimerView extends StatelessWidget {
  TimerView({
    super.key,
    required this.t,
  });

  final TimerClock t;

  final numFormat = NumberFormat('00', 'en_US');

  

  @override
  Widget build(BuildContext context) {
  
  final theme = Theme.of(context);
  final timeStyle = theme.textTheme.displayMedium;//!.copyWith(color: theme.colorScheme.onSecondary);
  // final cardStyle = theme.colorScheme.primary;
  
    return Center(
      child: Card(
        child: InkWell(
          onLongPress: () => {
            print('Long pressed this one')
          },
          onTap: () => { 
            t.toggleTimer()
          },
          child: SizedBox(
            height: 120,
            width: 180,
            child: Center(
              child: Text(
                '${numFormat.format(t.running.inMinutes)}:${numFormat.format(t.running.inSeconds%60)}',
                style: timeStyle
                ),
            ),
            ),
        ),
      ),
    );
  }
}
