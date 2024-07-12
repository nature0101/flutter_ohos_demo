import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'native_channel.dart';

void main() {
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
  int _counter = 0;
  OpenNativePlugin native = OpenNativePlugin();
  String localData = "";

  void _incrementCounter() {
    setState(() {
      _counter++;
      saveCountStore(_counter);
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getCountFromStore().then((value) {
        setState(() {
          _counter = value;
        });
      });
    });
    super.initState();
  }

  Future<int> getCountFromStore() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt('count_key') ?? 0;
  }

  Future<void> saveCountStore(int count) async {
    final sp = await SharedPreferences.getInstance();
    sp.setInt('count_key', count);
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
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 50),
            InkWell(
              child: const Text('打开原生页面'),
              onTap: () {
                native.openNative("我是flutter来的数据");
              },
            ),
            const SizedBox(height: 50),
            InkWell(
              child: Text('从原生获取的数据:${localData}'),
              onTap: () {
                native.getDataFromNative({"key": "flutter"}).then((value) {
                  setState(() {
                    localData = value ?? "";
                  });
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
