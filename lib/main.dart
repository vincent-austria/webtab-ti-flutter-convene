import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'constants.dart' as Constants;
import 'routes.dart';
import 'login.dart';
import 'meeting.dart';

void main() => runApp(MyApp());

HttpClient httpClient;
List<Cookie> cookies;
String xsrfToken;

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    httpClient = new HttpClient();
    cookies = new List();
    print('MAIN build. Client: ' + httpClient.toString());

    return MaterialApp(
      title: 'Convene Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: FirstRoute(), // LoginPage(),
      initialRoute: '/login',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        // '/': (context) => DummyHomePage(),
        '/': (context) => LoginPage(),
        '/login': (context) => LoginPage(),
        '/meetings': (context) => MeetingsPage(),
        '/first': (context) => FirstRoute(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/second': (context) => SecondRoute(),
      },
    );
  }
}

class DummyHomePage extends StatefulWidget {

  DummyHomePage() : super();

  @override
  _DummyHomePageState createState() => _DummyHomePageState();

}

class _DummyHomePageState extends State<DummyHomePage> {
  int _counter = 0;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('_LoginPageState INIT');
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('DUMMY build');
    return Scaffold(
      appBar: AppBar(
        title: Text(Constants.appTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            FavoriteWidget(),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                    ),
                    controller: TextEditingController(text: 'INIT'),
                    onSaved: (String value) {
                      print("onSaved $value");
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate will return true if the form is valid, or false if
                        // the form is invalid.
                        Navigator.pushNamed(context, '/login');
                        if (_formKey.currentState.validate()) {
                          print('ZZZ ' + _formKey.currentState.context.toString());
                          // Navigator.pushNamed(context, '/first');
                          // Process data.
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Future<Album> a = fetchAlbum();
                        a.then((value) => print('ALBUM ' + value.title));
                      },
                      child: Text('HTTP'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Future<Album> fetchAlbum() async {
    final response = await http.get('https://jsonplaceholder.typicode.com/albums/1');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Album.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

}

class Album {
  final int userId;
  final int id;
  final String title;

  Album({this.userId, this.id, this.title});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}

class FavoriteWidget extends StatefulWidget {
  @override
  _FavoriteWidgetState createState() => _FavoriteWidgetState();
}

class _FavoriteWidgetState extends State<FavoriteWidget> {
  bool _isFavorite = true;
  int _favoriteCount = 41;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(0),
          child: IconButton(
            padding: EdgeInsets.all(0),
            alignment: Alignment.centerRight,
            icon: (_isFavorite ? Icon(Icons.star) : Icon(Icons.star_border)),
            color: Colors.red[500],
            onPressed: _toggleFavorite,
          ),
        ),
        SizedBox(
          width: 18,
          child: Container(
            child: Text('$_favoriteCount'),
          ),
        ),
      ],
    );
  }

  void _toggleFavorite() {
    setState(() {
      if (_isFavorite) {
        _favoriteCount -= 1;
        _isFavorite = false;
      } else {
        _favoriteCount += 1;
        _isFavorite = true;
      }
    });
  }

}