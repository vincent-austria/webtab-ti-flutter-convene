import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

import 'constants.dart' as Constants;
import 'main.dart' as Main;

class MeetingsPage extends StatefulWidget {
  MeetingsPage() : super();

  @override
  _MeetingsPageState createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {

  final List<dynamic> meetings = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('MEETING init');
    fetchMeetings();
  }

  @override
  Widget build(BuildContext context) {
    print('MEETING build');
    return Scaffold(
      appBar: AppBar(
        //title: Text(Constants.appTitle),
        title: Text(Constants.appTitle + ' Meetings'),
      ),
      body:
      //Row(
        //children: [
          // ElevatedButton(onPressed: () => fetchMeetings(), child: Text('Fetch meetings')),
          buildMeetingsList()
        //],
      //)
    );
  }

  Widget buildMeetingsList() {
    return ListView.separated(
        itemBuilder: (context, i) {
          dynamic meeting = meetings.elementAt(i);
          return ListTile(
            title: Text(meeting['title']),
            trailing: Text(meeting['schedule']),
          );
        },
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemCount: meetings.length);
  }

  checkServer() {
    print('MEETING checkServer');
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
    print('MEETING checkSession');
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
    print('MEETING doLogin');
    Main.httpClient.postUrl(Uri.parse('https://wbc-test.azeusconvene.com/api/session'))
        .then((HttpClientRequest request) {
      if (Main.xsrfToken != null) {
        request.headers.add('X-XSRF-TOKEN', Main.xsrfToken);
      }
      request.headers.contentType = new ContentType("application", "json", charset: "utf-8");
      Main.cookies.forEach((cookie) => request.cookies.add(cookie));
      request.write('{"username":"vince","password":"testing123"}');
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
      });
      response.transform(utf8.decoder).listen((contents) {
        // print('CONTENTS $contents');
      });
      fetchMeetings();
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
        List<dynamic> parsedMeetings = json['meetings'];
        meetings.clear();
        parsedMeetings.forEach((parsedMeeting) {
          meetings.add(parsedMeeting);
        });
        print('PARSED pages $pages');
        // print('PARSED meetings ' + meetings.toString());
        meetings.forEach((meeting) {
          String meetingId = meeting['id'];
          String meetingSchedule = meeting['schedule'];
          String meetingTitle = meeting['title'];
          print('PARSED meeting id $meetingId name $meetingTitle schedule $meetingSchedule');
        });
      });
      setState(() {});
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
