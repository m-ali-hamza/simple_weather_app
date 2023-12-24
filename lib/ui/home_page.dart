import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:weather_app/component/weather_item.dart';
import 'package:weather_app/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController cityController = TextEditingController();
  Constants myConstants = Constants();
  static String apiKey = "b58517cc43d54251a5a120227231609";
  String location = 'London';
  String weatherIcon = 'heavycloudy.png';
  int temprature = 0;
  int windSpeed = 0;
  int humidity = 0;
  int cloud = 0;
  String currentDate = '';
  List hourlyWeatherForecast = [];
  List dailyWeatherForecast = [];

  String currentWeatherStatus = '';

  //Api Call
  String searchWeatherApi =
      "https://api.weatherapi.com/v1/forecast.json?key=$apiKey&days=7&q=";

  void fetchWeatherData(String searchText) async {
    try {
      var searchResult =
          await http.get(Uri.parse(searchWeatherApi + searchText));
      final weatherData =
          Map<String, dynamic>.from(jsonDecode(searchResult.body) ?? "No Data");
      var locationData = weatherData['location'];
      var currentWeather = weatherData['current'];

      setState(() {
        location = getShortLocationName(locationData['name']);

        //get current date
        var parsedDate =
            DateTime.parse(locationData['localtime'].substring(0, 10));
        var newDate = DateFormat("MMMMEEEEd").format(parsedDate);
        currentDate = newDate;

        //Update weather
        currentWeatherStatus = currentWeather['condition']['text'];
        weatherIcon =
            currentWeatherStatus.replaceAll(' ', '').toLowerCase() + ".png";
        temprature = currentWeather['temp_c'].toInt();
        windSpeed = currentWeather['wind_kph'].toInt();
        humidity = currentWeather['humidity'].toInt();
        cloud = currentWeather['cloud'].toInt();

        //Forecast Data
        dailyWeatherForecast = weatherData['forecast']['forecastday'];
        hourlyWeatherForecast = dailyWeatherForecast[0]['hour'];
      });
    } catch (e) {}
  }

//the function return the first two name of the string location
  static String getShortLocationName(String s) {
    List<String> wordList = s.split(" ");
    if (wordList.isNotEmpty) {
      if (wordList.length > 1) {
        return wordList[0] + " " + wordList[1];
      } else {
        return wordList[0];
      }
    } else {
      return " ";
    }
  }

  @override
  void initState() {
    fetchWeatherData(location);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Container(
          width: size.width,
          height: size.height,
          padding: EdgeInsets.all(size.width * .02),
          margin: EdgeInsets.only(top: size.width * .05),
          color: myConstants.primaryColor.withOpacity(.1),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: size.width * .02, horizontal: size.width * .02),
              height: size.height * .65,
              decoration: BoxDecoration(
                  gradient: myConstants.linearGradientBlue,
                  boxShadow: [
                    BoxShadow(
                        color: myConstants.primaryColor.withOpacity(.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3))
                  ],
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/menu.png",
                        width: size.width * .08,
                        height: size.width * .08,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            "assets/pin.png",
                            width: size.width * .04,
                          ),
                          Text(
                            location,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                          IconButton(
                              onPressed: () {
                                cityController.clear();
                                showMaterialModalBottomSheet(
                                    context: context,
                                    builder: (context) => SingleChildScrollView(
                                          controller:
                                              ModalScrollController.of(context),
                                          child: Container(
                                            height: size.height * .2,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: size.width * .06,
                                                vertical: size.width * .02),
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: 70,
                                                  child: Divider(
                                                    thickness: 3.5,
                                                    color: myConstants
                                                        .primaryColor,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                TextField(
                                                  onChanged: (searchText) {
                                                    fetchWeatherData(
                                                        searchText);
                                                  },
                                                  controller: cityController,
                                                  autofocus: true,
                                                  decoration: InputDecoration(
                                                      prefixIcon: Icon(
                                                        Icons.search,
                                                        color: myConstants
                                                            .primaryColor,
                                                      ),
                                                      suffixIcon:
                                                          GestureDetector(
                                                        onTap: () =>
                                                            cityController
                                                                .clear(),
                                                        child: Icon(
                                                          Icons.close,
                                                          color: myConstants
                                                              .primaryColor,
                                                        ),
                                                      ),
                                                      hintText:
                                                          "Search city e.g. London",
                                                      focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: myConstants
                                                                  .primaryColor),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10))),
                                                )
                                              ],
                                            ),
                                          ),
                                        ));
                              },
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ))
                        ],
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/profile.png',
                          width: size.width * .08,
                          height: size.width * .08,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: size.width * .3,
                    child: Image.asset("assets/" + weatherIcon),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          temprature.toString(),
                          style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()..shader = myConstants.shader),
                        ),
                      ),
                      Text(
                        "o",
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()..shader = myConstants.shader),
                      ),
                    ],
                  ),
                  Text(
                    currentWeatherStatus,
                    style: const TextStyle(fontSize: 20, color: Colors.white70),
                  ),
                  Text(
                    currentDate,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: size.width * .08),
                    child: const Divider(color: Colors.white70),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      WeatherItem(
                        value: windSpeed.toInt(),
                        unit: "km/h",
                        imageUrl: "assets/windspeed.png",
                      ),
                      WeatherItem(
                        value: humidity.toInt(),
                        unit: "%",
                        imageUrl: "assets/humidity.png",
                      ),
                      WeatherItem(
                        value: cloud.toInt(),
                        unit: "%",
                        imageUrl: "assets/cloud.png",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 10),
              height: size.height * .20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Today',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: myConstants.primaryColor),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Forecasts',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: myConstants.primaryColor),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: size.width * .23,
                    child: ListView.builder(
                        itemCount: hourlyWeatherForecast.length,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          String currenttime =
                              DateFormat("HH:mm:ss").format(DateTime.now());
                          String currentHour = currenttime.substring(0, 2);

                          String forecastTime = hourlyWeatherForecast[index]
                                  ['time']
                              .substring(11, 16);

                          String forecastHour = hourlyWeatherForecast[index]
                                  ['time']
                              .substring(11, 13);
                          String forecastWeatherName =
                              hourlyWeatherForecast[index]['condition']['text'];
                          String forecastWeatherIcon = forecastWeatherName
                                  .replaceAll(' ', '')
                                  .toLowerCase() +
                              ".png";

                          String forecastTemprature =
                              hourlyWeatherForecast[index]['temp_c']
                                  .round()
                                  .toString();

                          return Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.width * .01),
                            margin: EdgeInsets.only(right: size.width * .04),
                            width: size.width * .15,
                            decoration: BoxDecoration(
                                color: currentHour == forecastHour
                                    ? Colors.white
                                    : myConstants.primaryColor,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                boxShadow: [
                                  BoxShadow(
                                      offset: const Offset(0, 3),
                                      blurRadius: 5,
                                      color: myConstants.primaryColor
                                          .withOpacity(.2))
                                ]),
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    forecastTime,
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: myConstants.greyColor,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Image.asset(
                                    "assets/" + forecastWeatherIcon,
                                    width: size.width * .06,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(forecastTemprature,
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: myConstants.greyColor,
                                              fontWeight: FontWeight.w600)),
                                      Text("o",
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: myConstants.greyColor,
                                              fontWeight: FontWeight.w600,
                                              fontFeatures: const [
                                                FontFeature.enable('sups')
                                              ])),
                                    ],
                                  )
                                ]),
                          );
                        }),
                  )
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
