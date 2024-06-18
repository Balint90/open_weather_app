import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_weather_app/consts.dart';
import 'package:open_weather_app/themeNotifier.dart';
import 'package:weather/weather.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _locationTextController = TextEditingController();
  final WeatherFactory _weatherFactory = WeatherFactory(OPENWEATHER_API_KEY);
  Weather? _weather;

  @override
  void initState() {
    super.initState();
    _weatherFactory.currentWeatherByCityName("Pécs").then((w) {
      setState(() {
        _weather = w;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // resizeToAvoidBottomInset: false,
      appBar: _header(),
      body: SingleChildScrollView(child: _buildUI()),
    );
  }

  getWeatherInfo() async {
    try {
      if (_locationTextController.text.isNotEmpty) {
        _weatherFactory
            .currentWeatherByCityName(_locationTextController.text)
            .then((w) {
          setState(() {
            _weather = w;
            _locationTextController.clear();
          });
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  PreferredSizeWidget _header() {
    final currentTheme = ref.read(themeProvider);
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      centerTitle: false,
      elevation: 1,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Weather App"),
          GestureDetector(
            child: Row(
              children: [
                (currentTheme == ThemeMode.dark)
                    ? Icon(Icons.light_mode,
                        color: Theme.of(context).colorScheme.secondary)
                    : Icon(Icons.dark_mode,
                        color: Theme.of(context).colorScheme.primary),
              ],
            ),
            onTap: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUI() {
    if (_weather == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.02,
            ),
            _userInput(),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.001,
            ),
            _locationHeader(),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.02,
            ),
            _dateTimeInfo(),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.002,
            ),
            _weatherIcon(),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.02,
            ),
            _currentTemp(),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.02,
            ),
            _extraInfo(),
          ]),
    );
  }

  Widget _userInput() {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: 32.0, top: 16.0, left: 16.0, right: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _locationTextController,
                style: Theme.of(context).textTheme.titleSmall,
                decoration: InputDecoration(
                    hintText: "Location",
                    hintStyle: Theme.of(context).textTheme.titleSmall,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20)),
              ),
            ),
            const SizedBox(width: 8.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: getWeatherInfo,
                child: Icon(Icons.search,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationHeader() {
    return Text(
      _weather?.areaName ?? "",
      style: Theme.of(context).textTheme.titleLarge?.merge(
            const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
    );
  }

  Widget _dateTimeInfo() {
    DateTime now = _weather!.date!;
    return Column(
      children: [
        Text(
          DateFormat("h:mm a").format(now),
          style: Theme.of(context).textTheme.titleLarge?.merge(
                const TextStyle(
                  fontSize: 35,
                ),
              ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat("EEEE").format(now),
              style: Theme.of(context).textTheme.titleLarge?.merge(
                    const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            ),
            Text(
              " ${DateFormat("d.M.y").format(now)}",
              style: Theme.of(context).textTheme.titleLarge?.merge(
                    const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            ),
          ],
        )
      ],
    );
  }

  Widget _weatherIcon() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.sizeOf(context).height * 0.20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  "http://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"),
            ),
          ),
        ),
        Text(
          _weather?.weatherDescription ?? "",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

  Widget _currentTemp() {
    return Text(
      "${_weather?.temperature?.celsius?.toStringAsFixed(0)}° C",
      style: Theme.of(context).textTheme.titleMedium?.merge(
            const TextStyle(
              fontSize: 70,
              fontWeight: FontWeight.w500,
            ),
          ),
    );
  }

  Widget _extraInfo() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.15,
      width: MediaQuery.sizeOf(context).width * 0.80,
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Max: ${_weather?.tempMax?.celsius?.toStringAsFixed(0)}° C",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              Text(
                "Min: ${_weather?.tempMin?.celsius?.toStringAsFixed(0)}° C",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Wind: ${_weather?.windSpeed?.toStringAsFixed(0)}m/s",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              Text(
                "Humidity: ${_weather?.humidity?.toStringAsFixed(0)}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
