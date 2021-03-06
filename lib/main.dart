import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

var city;
                                                            // weather App
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(fontFamily: 'Magic'),                                                        // Card Widget
    home: ApiPage(),
  ));
}

Future<Req> fetchReq(String city) async {
  final response = await http.get(
      'http://api.weatherapi.com/v1/current.json?key=d1b40ed2caa04e3b8df92757211501&q=$city');

  if (response.statusCode == 200) {
    return Req.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failure!');
  }
}

class ApiPage extends StatefulWidget {
  @override
  _ApiPageState createState() => _ApiPageState();
}

class _ApiPageState extends State<ApiPage> {
  Future<Req> futureReq;
  var currDt = DateTime.now();

  TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    super.initState();

    futureReq = fetchReq("noida");
  }

  @override
  Widget build(BuildContext context) {
    String assetImage = 'images/drops.jpg';
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(assetImage), fit: BoxFit.cover),
            ),
          ),
          Center(
            child: Column(children: <Widget>[
              Container(
                child: Text(
                  "Type in 'city' name and press the search icon",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                margin: EdgeInsets.fromLTRB(40, 80, 40, 0),
              ),
              Stack(children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(40, 10, 40, 0),
                  child: TextField(
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      controller: controller,
                      autofocus: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.white)),
                        contentPadding: EdgeInsets.all(10),
                        hintText: 'enter city name',
                        hintStyle: TextStyle(color: Colors.white, fontSize: 20),
                      )),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(350, 10, 40, 0),
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          city = controller.text;
                          futureReq = fetchReq(city);
                        });
                      },
                      icon: Icon(
                        Icons.search,
                        color: Colors.white,
                      )),
                ),
              ]),
              FutureBuilder<Req>(
                  future: futureReq,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        margin: EdgeInsets.fromLTRB(20, 80, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.network(
                                'http:' + snapshot.data.current.condition.icon),
                            Text(
                              snapshot.data.location.name,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              snapshot.data.location.region,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              snapshot.data.location.country,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    SizedBox(
                                      width: 110,
                                    ),
                                    Text(
                                      snapshot.data.current.tempC.toString(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 65),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "°C",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 65),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  snapshot.data.current.condition.text,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 30),
                                )
                              ],
                            ),
                            SizedBox(
                              width: 100,
                            ),
                          ],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Container(
                        margin: EdgeInsets.fromLTRB(0, 200, 0, 0),
                        child: Text(
                          'city not found',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              letterSpacing: 2),
                        ),
                      );
                    }
                    return CircularProgressIndicator();
                  }),
            ]),
          ),
        ],
      ),
    );
  }
}

class Req {
  Location location;
  Current current;

  Req({this.location, this.current});

  Req.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    current =
        json['current'] != null ? new Current.fromJson(json['current']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.location != null) {
      data['location'] = this.location.toJson();
    }
    if (this.current != null) {
      data['current'] = this.current.toJson();
    }
    return data;
  }
}

class Location {
  String name;
  String region;
  String country;

  Location({this.name, this.region, this.country});

  Location.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    region = json['region'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['region'] = this.region;
    data['country'] = this.country;
    return data;
  }
}

class Current {
  double tempC;
  Condition condition;

  Current({this.tempC, this.condition});

  Current.fromJson(Map<String, dynamic> json) {
    tempC = json['temp_c'];
    condition = json['condition'] != null
        ? new Condition.fromJson(json['condition'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['temp_c'] = this.tempC;
    if (this.condition != null) {
      data['condition'] = this.condition.toJson();
    }
    return data;
  }
}

class Condition {
  String text;
  String icon;

  Condition({this.text, this.icon});

  Condition.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    icon = json['icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    data['icon'] = this.icon;
    return data;
  }
}
