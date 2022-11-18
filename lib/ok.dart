import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IOT LAP',
      theme: ThemeData(
          fontFamily: "Poppins",
          sliderTheme: const SliderThemeData(
            trackShape: RectangularSliderTrackShape(),
            trackHeight: 2.5,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 15.0),
          )),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  late List<LiveData> chartData;
  late ChartSeriesController _chartSeriesController;
  void initState() {
    chartData = getChartData();
    Timer.periodic(const Duration(seconds: 1), updateDataSource);
    super.initState();
  }

  List<LiveData> _LiveData = <LiveData>[];
  double temperature = 16;
  double humidity = 70;
  bool status = true;
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void setchart(x) {
    humidity = x;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.menu, color: Color.fromARGB(95, 7, 54, 52)),
        title: Text('IOT MONITOR',
            style: TextStyle(
                color: Color.fromARGB(255, 26, 136, 132), fontSize: 25)),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                  "https://scontent.fsgn8-3.fna.fbcdn.net/v/t39.30808-6/302186395_912832226772687_3825116247837812466_n.jpg?_nc_cat=106&ccb=1-7&_nc_sid=174925&_nc_ohc=ghWKdQc0pC0AX9pIPXV&_nc_ht=scontent.fsgn8-3.fna&oh=00_AfDLIVLRDV6UAZpgD0G3LrvoklX9oRF9HooakjKjA1T8jg&oe=637AB802"), //NetworkImage
              radius: 20,
            ),
          ),
        ],
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
      body: StreamBuilder(
        stream: FirebaseDatabase(
                databaseURL:
                    'https://myapp-81b37-default-rtdb.asia-southeast1.firebasedatabase.app')
            .ref('Data')
            .onValue,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData &&
              !snapshot.hasError &&
              snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> values =
                snapshot.data?.snapshot.value as Map<dynamic, dynamic>;
            final double temperature = values['Temperture'] + 0.0;
            final double humidity = values['Humidity'] + 0.0;

            setchart(humidity);
            return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                  Container(
                    height: 240,
                    child: SfCartesianChart(
                        title: ChartTitle(text: 'aTmostphere Quality'),
                        series: <LineSeries<LiveData, int>>[
                          LineSeries<LiveData, int>(
                            onRendererCreated:
                                (ChartSeriesController controller) {
                              _chartSeriesController = controller;
                            },
                            dataSource: chartData,
                            color: const Color.fromRGBO(192, 108, 132, 1),
                            xValueMapper: (LiveData sales, _) => sales.x,
                            yValueMapper: (LiveData sales, _) => sales.y,
                          )
                        ],
                        primaryXAxis: NumericAxis(
                            majorGridLines: const MajorGridLines(width: 0),
                            edgeLabelPlacement: EdgeLabelPlacement.shift,
                            interval: 3,
                            title: AxisTitle(text: 'Time (seconds)')),
                        primaryYAxis: NumericAxis(
                          axisLine: const AxisLine(width: 0),
                          majorTickLines: const MajorTickLines(size: 0),
                        )),
                  ),
                  Container(
                      height: 380,
                      margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                        border: Border.all(
                            width: 3,
                            color: Color.fromARGB(255, 223, 231, 230)),
                        color: Color.fromARGB(255, 254, 254, 254),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                  color: Color.fromARGB(255, 255, 177, 173),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: SleekCircularSlider(
                                  appearance: CircularSliderAppearance(
                                      animDurationMultiplier: 0.1,
                                      customWidths: CustomSliderWidths(
                                          progressBarWidth: 10),
                                      customColors: CustomSliderColors(
                                          progressBarColors: [
                                            Color.fromARGB(255, 236, 23, 23),
                                            Color.fromARGB(255, 95, 1, 1)
                                          ],
                                          trackColor:
                                              Color.fromARGB(255, 198, 22, 9),
                                          hideShadow: true),
                                      infoProperties: InfoProperties(
                                          bottomLabelText: 'Temperature',
                                          modifier: (double value) {
                                            final temp = value.toString();

                                            return '$temp °C ';
                                          })),
                                  min: 10,
                                  max: 60,
                                  initialValue: temperature,
                                )),
                            Container(
                                margin: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                  color: Color.fromARGB(255, 141, 204, 241),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: SleekCircularSlider(
                                  appearance: CircularSliderAppearance(
                                      customWidths: CustomSliderWidths(
                                          progressBarWidth: 10),
                                      customColors: CustomSliderColors(
                                          progressBarColors: [
                                            Color.fromARGB(255, 46, 132, 202),
                                            Color.fromARGB(255, 4, 43, 120)
                                          ],
                                          trackColor:
                                              Color.fromARGB(255, 17, 90, 149),
                                          hideShadow: true),
                                      infoProperties: InfoProperties(
                                          bottomLabelText: 'Humidity',
                                          modifier: (double value) {
                                            final temp =
                                                value.ceil().toString();
                                            return ' $temp % ';
                                          })),
                                  min: 10,
                                  max: 100,
                                  initialValue: humidity,
                                ))
                          ]),
                          Container(
                              width: 350,
                              height: 170,
                              margin: EdgeInsets.only(left: 10, right: 10),
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                color: Color.fromARGB(255, 181, 218, 220),
                              ),
                              padding: const EdgeInsets.all(0),
                              child: Container(
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                    Text('THE LIGHT',
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 0, 73, 68))),
                                    FlutterSwitch(
                                      width: 125.0,
                                      height: 55.0,
                                      valueFontSize: 25.0,
                                      toggleSize: 45.0,
                                      value: status,
                                      borderRadius: 30.0,
                                      padding: 8.0,
                                      showOnOff: true,
                                      onToggle: (val) {
                                        setState(() {
                                          status = val;
                                        });
                                        writeData(status);
                                      },
                                    )
                                  ]))),
                        ],
                      ))
                ]));
            ;
          } else {
            return const Text("Nodata");
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'House',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.yard),
            label: 'Garden',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.garage_rounded),
            label: 'Garage',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 36, 142, 133),
        onTap: _onItemTapped,
      ),
    );
  }

  int time = 19;
  void updateDataSource(Timer timer) {
    chartData.add(LiveData(
      time++,humidity
    ));
    chartData.removeAt(0);
    _chartSeriesController.updateDataSource(
        addedDataIndex: chartData.length - 1, removedDataIndex: 0);
  }

  List<LiveData> getChartData() {
    return <LiveData>[
      LiveData(0, 73),
      LiveData(1, 72),
      LiveData(2, 43),
      LiveData(3, 49),
      LiveData(4, 54),
      LiveData(5, 41),
      LiveData(6, 58),
      LiveData(7, 51),
      LiveData(8, 98),
      LiveData(9, 41),
      LiveData(10, 53),
      LiveData(11, 72),
      LiveData(12, 86),
      LiveData(13, 52),
      LiveData(14, 94),
      LiveData(15, 92),
      LiveData(16, 86),
      LiveData(17, 72),
      LiveData(18, 94)
    ];
  }
}

Future<void> writeData(status) async {
  DatabaseReference ref = FirebaseDatabase(
          databaseURL:
              'https://myapp-81b37-default-rtdb.asia-southeast1.firebasedatabase.app')
      .ref('Data');
  if (status == true) {
    await ref.update({"Light": 1});
  } else {
    await ref.update({"Light": 0});
  }
}

class LiveData {
  LiveData(this.x, this.y);
  final int x;
  final num y;
}
