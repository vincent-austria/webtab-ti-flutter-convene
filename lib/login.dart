import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

import 'constants.dart' as Constants;
import 'main.dart' as Main;

class LoginPage extends StatefulWidget {
  LoginPage() : super();

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // final _formKey = GlobalKey<FormState>();

  final resourceController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('LOGIN init');
    resourceController.text = 'https://wbc-test.azeusconvene.com';
    usernameController.text = 'vince';
    passwordController.text = 'testing123';
  }

  @override
  Widget build(BuildContext context) {
    print('LOGIN build');
    return Scaffold(
      appBar: AppBar(
        title: Text(Constants.appTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                hintText: 'https://wbc-test.azeusconvene.com',
                border: OutlineInputBorder(),
                labelText: 'Resource URL',
              ),
              controller: resourceController,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(),
                labelText: 'Username or Email',
              ),
              controller: usernameController,
              // onSaved: (String value) => print("onSaved $value"),
              // validator: (String value) => value.isEmpty ? '' : null,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter your password',
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
              obscureText: true,
              controller: passwordController,
              // controller: TextEditingController(text: 'INIT'),
              // onSaved: (String value) => print("onSaved $value"),
              // validator: (String value) => value.isEmpty ? '' : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Validate will return true if the form is valid, or false if
                  // the form is invalid.
                  //if (_formKey.currentState.validate()) {
                    // Navigator.pushNamed(context, '/first');
                    // Process data.

                    //checkServer();
                    checkSession();


                  //}
                },
                child: Text('Login'),
              ),
            ),          ],
        ),
      ),
    );
  }

  checkServer() {
    print('LOGIN checkServer');
    Main.httpClient.getUrl(Uri.parse('https://wbc-test.azeusconvene.com/api/server'))
        .then((HttpClientRequest request) {
      return request.close();
    }).then((HttpClientResponse response) {
      print('RESPONSE ' + response.statusCode.toString());
      response.headers.forEach((name, values) {
        // print('HEADER ' + name + ' ' + values.toString());
      });
      response.cookies.forEach((cookie) {
        print('COOKIE ' + cookie.name + ' ' + cookie.value);
      });
      response.transform(utf8.decoder).listen((contents) {
        print('CONTENTS $contents');
      });
    });
  }

  checkSession() {
    print('LOGIN checkSession');
    Main.httpClient.getUrl(Uri.parse('https://wbc-test.azeusconvene.com/api/session'))
        .then((HttpClientRequest request) {
      return request.close();
    }).then((HttpClientResponse response) {
      print('RESPONSE ' + response.statusCode.toString());
      response.headers.forEach((name, values) {
        // print('HEADER ' + name + ' ' + values.toString());
      });
      response.cookies.forEach((cookie) {
        print('COOKIE ' + cookie.name + ' ' + cookie.value);
        Main.cookies.add(cookie);
        print('COOKIE added, length: ' + Main.cookies.length.toString());
        if(cookie.name == "XSRF-TOKEN") {
          Main.xsrfToken = cookie.value;
        }
      });
      response.transform(utf8.decoder).listen((contents) {
        print('CONTENTS $contents');
      });
      doLogin();
    });
  }

  doLogin() {
    print('LOGIN doLogin');
    Main.httpClient.postUrl(Uri.parse('https://wbc-test.azeusconvene.com/api/session'))
        .then((HttpClientRequest request) {
          if (Main.xsrfToken != null) {
            request.headers.add('X-XSRF-TOKEN', Main.xsrfToken);
          }
          request.headers.contentType = new ContentType("application", "json", charset: "utf-8");
          Main.cookies.forEach((cookie) => request.cookies.add(cookie));
          request.write('{"username":"${usernameController.text}","password":"${passwordController.text}"}');
      return request.close();
    }).then((HttpClientResponse response) {
      int responseCode = response.statusCode;
      print('RESPONSE LOGIN $responseCode');
      if (responseCode != 200) {
        response.transform(utf8.decoder).listen((contents) {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(content: Text(contents)),
          );
          return;
        });
      } else {
        response.headers.forEach((name, values) {
          // print('HEADER ' + name + ' ' + values.toString());
        });
        response.cookies.forEach((cookie) {
          print('COOKIE ' + cookie.name + ' ' + cookie.value);
          Main.cookies.add(cookie);
          print('COOKIE added, length: ' + Main.cookies.length.toString());
        });
        //response.transform(utf8.decoder).listen((contents) {
        // print('CONTENTS $contents');
        //});
        // fetchMeetings();
        Navigator.pushNamed(context, '/meetings');
      }
    });
  }

  fetchMeetings() {
    print('MEETINGS fetchMeetings');
    Main.httpClient.getUrl(Uri.parse('https://wbc-test.azeusconvene.com/api/meetings'))
        .then((HttpClientRequest request) {
      if (Main.xsrfToken != null) {
        request.headers.add('X-XSRF-TOKEN', Main.xsrfToken);
      }
      // request.headers.contentType = new ContentType("application", "json", charset: "utf-8");
      Main.cookies.forEach((cookie) => request.cookies.add(cookie));
      // request.write('{"username":"vince","password":"testing123"}');
      return request.close();
    }).then((HttpClientResponse response) {
      print('RESPONSE ' + response.statusCode.toString());
      response.headers.forEach((name, values) {
        // print('HEADER ' + name + ' ' + values.toString());
      });
      response.cookies.forEach((cookie) {
        print('COOKIE ' + cookie.name + ' ' + cookie.value);
      });
      response.transform(utf8.decoder).listen((contents) {
        print('CONTENTS $contents');
        dynamic json = jsonDecode(contents);
        int pages = json['pages'];
        List<dynamic> meetings = json['meetings'];
        print('PARSED pages $pages');
        // print('PARSED meetings ' + meetings.toString());
        meetings.forEach((meeting) {
          String meetingId = meeting['id'];
          String meetingSchedule = meeting['schedule'];
          String meetingTitle = meeting['title'];
          print('PARSED meeting id $meetingId name $meetingTitle schedule $meetingSchedule');
        });
      });
    });
  }

  /*
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
   */

}
