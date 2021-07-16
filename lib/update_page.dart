import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:solat_app/main.dart';
import 'package:solat_app/update_set_data.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

StreamController<List<dynamic>> stream2 = BehaviorSubject();

class PageTwo extends StatelessWidget {
  const PageTwo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UpdatePage(stream2.stream);
  }
}

class UpdatePage extends StatefulWidget {
  final Stream<List<dynamic>> stream;

  UpdatePage(this.stream);

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  static String cityNow = "-";
  static String dropDownValue = "Ambarawa";
  List<dynamic> listCity = [];

  void getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    cityNow = preferences.getString('city2') ?? "Jakarta Pusat";
  }

  Future<void> startUpdate() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final directory = await getApplicationDocumentsDirectory();
    File file = new File('${directory.path}/data_kota.cfg');

    String city;
    String cityFix = "";
    var id;

    if (file.existsSync()) {
      await file
          .openRead()
          .map(utf8.decode)
          .transform(new LineSplitter())
          .forEach((dataAndNum) {
        city = dataAndNum.split(" : ")[1];
        if (city == dropDownValue) {
          id = dataAndNum.split(":")[0];
          cityFix = city;
          preferences.setString('city2', cityFix);
        }
      });
    }
    try {
      http.Response response = await http
          .get(Uri.parse('https://jadwalsholat.org/adzan/monthly.php?id=$id'))
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        UpdateData upData = new UpdateData(response, directory.path);
        upData.getCity();
        upData.getParam();
        upData.getTable();

        SetData setData = new SetData(directory.path);
        var data = await setData.setParams();
        var schedule = await setData.setTable();

        List scriptUpdate = [data, schedule, cityFix];
        streamController.add(scriptUpdate);

        setState(() {
          cityNow = cityFix;
        });

        Fluttertoast.showToast(
          msg: 'Lokasi telah dirubah! ($cityFix)',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } on TimeoutException catch (e) {
      Fluttertoast.showToast(
        msg: 'Timeout Exception: Ulangi kembali\n($e)',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    getPref();

    widget.stream.listen((data) {
      setListCityFirst(data);
    });
  }

  void setListCityFirst(data) {
    setState(() {
      listCity = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFEE8B60),
        centerTitle: true,
        elevation: 4,
        title: Text(
          'Update Lokasi',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 20,
            color: Color(0xFFFFFDFD),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(25, 25, 25, 0),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text(
                    'Pilih Kota',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
                Spacer(flex: 3),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: DropdownButton<dynamic>(
                    value: dropDownValue,
                    items: listCity.map<DropdownMenuItem>((var value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (var newValue) {
                      setState(() {
                        dropDownValue = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(25, 20, 25, 0),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text(
                    'Kota saat ini: ',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: Text(
                    cityNow,
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(45, 10, 45, 20),
            child: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  child: Text(
                    "Update",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                    ),
                  ),
                  onPressed: () => startUpdate(),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(35, 0, 35, 0),
            child: Align(
              alignment: Alignment.center,
              child: Row(
                children: [
                  Text("Data diambil dari "),
                  InkWell(
                    child: Text(
                      "jadwalsholat.org",
                      style: TextStyle(
                        color: Color(0xFF0000EE),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () => launch('http://jadwalsholat.org'),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
