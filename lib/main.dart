
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class Player {
  String name;
  int da;
  int biDa;

  Player(this.name, {this.da = 0, this.biDa = 0});

  int get tong => da + biDa;

  Map<String, dynamic> toJson() => {
        'name': name,
        'da': da,
        'biDa': biDa,
      };

  static Player fromJson(Map<String, dynamic> json) =>
      Player(json['name'], da: json['da'], biDa: json['biDa']);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ScorePage(),
    );
  }
}

class ScorePage extends StatefulWidget {
  @override
  _ScorePageState createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  List<Player> players = [
    Player("Người 1"),
    Player("Người 2"),
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    String data = jsonEncode(players.map((e) => e.toJson()).toList());
    await prefs.setString("players", data);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString("players");
    if (data != null) {
      List decoded = jsonDecode(data);
      setState(() {
        players = decoded.map((e) => Player.fromJson(e)).toList();
      });
    }
  }

  void addPlayer() {
    if (players.length < 4) {
      setState(() {
        players.add(Player("Người ${players.length + 1}"));
      });
      saveData();
    }
  }

  void resetAll() {
    setState(() {
      for (var p in players) {
        p.da = 0;
        p.biDa = 0;
      }
    });
    saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ghi điểm cá ngựa"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: resetAll,
          )
        ],
      ),
      floatingActionButton:
          FloatingActionButton(onPressed: addPlayer, child: Icon(Icons.add)),
      body: ListView(
        children: players.map((p) {
          return Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Đá: ${p.da}"),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => p.da++);
                          saveData();
                        },
                        child: Text("+"),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Bị đá: ${p.biDa}"),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => p.biDa++);
                          saveData();
                        },
                        child: Text("+"),
                      )
                    ],
                  ),
                  Text("Tổng: ${p.tong}"),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
