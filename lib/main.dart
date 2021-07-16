import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'update_page.dart';
import 'update_set_data.dart';

StreamController<List> streamController = new StreamController<List>();

void main() {
  runApp(PageOne());
}

class PageOne extends StatelessWidget {
  const PageOne({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SolatApp",
      home: HomePage(streamController.stream),
    );
  }
}

class HomePage extends StatefulWidget {
  final Stream<List> stream;

  HomePage(this.stream);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String terbitTime = '-';
  String shubuhTime = '-';
  String imsyakTime = '-';
  String dhuhaTime = '-';
  String dzuhurTime = '-';
  String maghribTime = '-';
  String ashrTime = '-';
  String isyaTime = '-';
  String param1 = '-';
  String param2 = '-';
  String param3 = '-';
  String city = '-';

  String tanggal = DateFormat('EEEE, d MMM, yyyy').format(DateTime.now());

  Future<void> getData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final directory = await getApplicationDocumentsDirectory();
    SetData setData = new SetData(directory.path);

    var params = await setData.setParams();
    List<dynamic> listCity = setData.setListCity();
    var schedule = await setData.setTable();

    var data = [params, schedule];
    stream2.add(listCity);

    setState(() {
      param1 = data[0][0];
      param2 = data[0][1];
      param3 = data[0][2];
      imsyakTime = data[1][1];
      shubuhTime = data[1][2];
      terbitTime = data[1][3];
      dhuhaTime = data[1][4];
      dzuhurTime = data[1][5];
      ashrTime = data[1][6];
      maghribTime = data[1][7];
      isyaTime = data[1][8];
      String citySet = preferences.getString('city') ?? "Jakarta Pusat";
      city = 'Wilayah $citySet';
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => getData());

    widget.stream.listen((data) {
      updateCity(data);
    });
  }

  void updateCity(List data) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      param1 = data[0][0];
      param2 = data[0][1];
      param3 = data[0][2];
      imsyakTime = data[1][1];
      shubuhTime = data[1][2];
      terbitTime = data[1][3];
      dhuhaTime = data[1][4];
      dzuhurTime = data[1][5];
      ashrTime = data[1][6];
      maghribTime = data[1][7];
      isyaTime = data[1][8];
      city = 'Wilayah ${data[2]}';
      preferences.setString('city', city);
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
          'SolatApp',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFFFFFDFD),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(25, 15, 0, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      city,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(25, 5, 0, 15),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      tanggal,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            getPadding('Imsyak', imsyakTime, Color(0xFFDCD68E)),
            getPadding('Shubuh', shubuhTime, Color(0xFFDCE69E)),
            getPadding('Terbit', terbitTime, Color(0xFFDCD68E)),
            getPadding('Dhuha', dhuhaTime, Color(0xFFDCE69E)),
            getPadding('Dzuhur', dzuhurTime, Color(0xFFDCD68E)),
            getPadding('Ashr', ashrTime, Color(0xFFDCE69E)),
            getPadding('Maghrib', maghribTime, Color(0xFFDCD68E)),
            getPadding('Isya', isyaTime, Color(0xFFDCE69E)),
            Padding(
              padding: EdgeInsets.fromLTRB(25, 10, 25, 0),
              child: Container(
                child: Column(
                  children: [
                    Divider(),
                    Text(
                      param1,
                      textAlign: TextAlign.center,
                    ),
                    Divider(),
                    Text(
                      param2,
                      textAlign: TextAlign.center,
                    ),
                    Divider(),
                    Text(
                      param3,
                      textAlign: TextAlign.center,
                    ),
                    Divider(),
                    Container(
                      width: 100,
                      height: 100,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset('assets/images/compass.png'),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(45, 10, 45, 20),
              child: Builder(
                builder: (context) => Center(
                  child: ElevatedButton(
                    child: Text(
                      "Update Lokasi",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => PageTwo()));
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Padding getPadding(String prayTime, String time, Color hexColor) {
  return Padding(
    padding: EdgeInsets.fromLTRB(25, 0, 25, 5),
    child: Container(
      width: 100,
      height: 50,
      decoration: BoxDecoration(
        color: hexColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Text(
              prayTime,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: Text(
              time,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
