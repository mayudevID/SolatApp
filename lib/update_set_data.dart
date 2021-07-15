import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'dart:convert';
import 'package:intl/intl.dart';

class UpdateData {
  late dom.Document document;
  var dirPath;

  UpdateData(http.Response response, var dir) {
    this.document = parser.parse(response.body);
    this.dirPath = dir;
  }

  void getParam() {
    var params = this.document.getElementsByTagName('tr').getRange(36, 39);
    var infoFiqh = this.document.getElementsByTagName('tr').getRange(40, 45);

    var dataParamsList = [];
    for (var data in params) {
      var dataParams = data.text;
      dataParamsList.add(dataParams);
    }

    var infoFiqhList = [];
    for (var data in infoFiqh) {
      var info = data.text;
      infoFiqhList.add(info);
    }

    var file = File('$dirPath/params.cfg');

    if (file.existsSync()) {
      file.deleteSync();
    }

    dataParamsList
        .forEach((k) => file.writeAsStringSync("$k\n", mode: FileMode.append));
    //infoFiqhList.forEach(
    //    (k) => file.writeAsStringSync("${k}\n", mode: FileMode.append));
  }

  void getTable() {
    var table = this.document.getElementsByClassName('table_adzan')[0];
    var tableBody = table.getElementsByTagName('tbody')[0];
    var monthSchedule = tableBody.getElementsByTagName('tr').getRange(4, 35);

    var jadwal = [];
    for (var day_schedule in monthSchedule) {
      var daySch = day_schedule.getElementsByTagName('td');
      var timeDay = [];
      for (var i = 0; i < daySch.length; i++) {
        timeDay.add(daySch[i].text.toString());
      }
      jadwal.add(timeDay);
    }

    var file = File('$dirPath/data_jadwal.cfg');

    if (file.existsSync()) {
      file.deleteSync();
    }

    jadwal
        .forEach((k) => file.writeAsStringSync("$k\n", mode: FileMode.append));
  }

  void getCity() {
    var city = {};
    var cities = this.document.getElementsByTagName('option');

    for (var i = 0; i < cities.length; i++) {
      var val = cities[i].attributes.values;
      // ignore: omit_local_variable_types
      String valStr = val.toString().replaceAll(')', '').replaceAll('(', '');
      city[valStr] = cities[i].text;
    }

    var file = File('$dirPath/data_kota.cfg');

    if (file.existsSync()) {
      file.deleteSync();
    }

    city.forEach(
        (k, v) => file.writeAsStringSync("$k : $v\n", mode: FileMode.append));
  }
}

class SetData {
  var dirPath;

  SetData(this.dirPath);

  List<dynamic> setListCity() {
    File file = File('$dirPath/data_kota.cfg');
    List<String> listCity = [];
    if (file.existsSync()) {
      file
          .openRead()
          .map(utf8.decode)
          .transform(new LineSplitter())
          .forEach((l) {
        String city = l.split(" : ")[1];
        listCity.add(city.toString());
      });
    }

    return listCity;
  }

  Future<List> setTable() async {
    File file = File('$dirPath/data_jadwal.cfg');
    var schedule = [];
    List scheduleNow = [];
    if (file.existsSync()) {
      await file
          .openRead()
          .map(utf8.decode)
          .transform(new LineSplitter())
          .forEach((l) => schedule.add(l));

      DateTime now = DateTime.now();
      DateFormat formatter = DateFormat('yyyy-MM-dd');
      String dateNow = formatter.format(now).split('-')[2];
      //print(dateNow);

      schedule.forEach((element) {
        String scheduleNew = element.replaceAll(']', '').replaceAll('[', '');
        List<String> scheduleList = scheduleNew.split(", ");
        String date = scheduleList[0].toString();
        //print(scheduleList);
        if (dateNow == date) {
          scheduleNow = scheduleList;
        }
      });
    }

    return scheduleNow;
  }

  Future<List> setParams() async {
    File file = File('$dirPath/params.cfg');
    List dataParams = [];
    if (file.existsSync()) {
      await file
          .openRead()
          .map(utf8.decode)
          .transform(new LineSplitter())
          .forEach((l) => dataParams.add(l));
    } else {
      bool checkTrue = await SetData.checkConn();
      if (checkTrue == true) {
        http.Response response = await http
            .get(Uri.parse('https://jadwalsholat.org/adzan/monthly.php'))
            .timeout(Duration(seconds: 10));
        //final directory = await getApplicationDocumentsDirectory();
        //print(directory.path);
        UpdateData upData = new UpdateData(response, dirPath);
        upData.getParam();
        upData.getCity();
        upData.getTable();

        SetData setData = new SetData(dirPath);
        dataParams = await setData.setParams();
      }
    }

    return dataParams;
  }

  static Future<bool> checkConn() async {
    bool checkTrue = false;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        checkTrue = true;
      } else {
        checkTrue = false;
      }
    } on TimeoutException {
      //print('Timeout Error: $e');
    } on SocketException {
      //print('Socket Error: $e');
    } on Error {
      //print('General Error: $e');
    }

    return checkTrue;
  }
}
