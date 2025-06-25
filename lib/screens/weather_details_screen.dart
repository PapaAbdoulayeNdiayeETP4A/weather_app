import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/models/forecast_response.dart';
import '../models/weather_response.dart';
import '../services/weather_api.dart';
import '../providers/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class WeatherDetailsScreen extends StatefulWidget {
  final String cityName;

  const WeatherDetailsScreen({super.key, required this.cityName});

  @override
  State<WeatherDetailsScreen> createState() => _WeatherDetailsScreenState();
}

class _WeatherDetailsScreenState extends State<WeatherDetailsScreen> {
  ForecastResponse? forecast;
  WeatherResponse? currentWeather;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  void openMap(double lat, double lon) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Impossible de lancer l’URL : $uri');
      }
    } catch (e) {
      debugPrint('Erreur: $e');
    }
  }

  Future<void> fetchWeather() async {
    try {
      final dio = Dio();
      final api = WeatherApi(dio);
      final resultForecast = await api.getForecastByCity(
        widget.cityName,
        "a815888716625f4d0475480e124cf089",
      );
      final resultCurrentWeather = await api.getWeatherByCity(
        widget.cityName,
        "a815888716625f4d0475480e124cf089",
      );

      setState(() {
        currentWeather = resultCurrentWeather;
        forecast = resultForecast;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  double kelvinToCelsius(double kelvin) {
    return kelvin - 273.15;
  }

  String getWeatherIcon(String icon) {
    final baseUrl = 'https://openweathermap.org/img/wn/';
    return '$baseUrl$icon@2x.png';
  }

  List<Color> getGradientColors(bool isDark) {
    if (isDark) {
      return [
        Colors.grey.shade800,
        Colors.grey.shade900,
        Colors.black87,
        Colors.black,
      ];
    } else {
      return [
        Colors.blueAccent.shade200,
        Colors.blueAccent.shade400,
        Colors.blueAccent.shade700,
        Colors.indigo.shade900,
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? Colors.black : Colors.black,
          body:
              isLoading
                  ? Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: getGradientColors(isDark),
                      ),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                  : error != null
                  ? Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: getGradientColors(isDark),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Erreur: $error",
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                                error = null;
                              });
                              fetchWeather();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor:
                                  isDark
                                      ? Colors.grey.shade800
                                      : Colors.blueAccent,
                            ),
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
                  )
                  : forecastWidget(isDark, themeProvider),
        );
      },
    );
  }

  Widget forecastWidget(bool isDark, ThemeProvider themeProvider) {
    final tempCelsius = kelvinToCelsius(currentWeather!.main.temp);
    final weather = currentWeather!.weather[0];
    final description = weather.description;
    final icon = weather.icon;
    final sunrise =
        DateTime.fromMillisecondsSinceEpoch(
          forecast!.city.sunrise * 1000,
          isUtc: true,
        ).toLocal();
    final sunset =
        DateTime.fromMillisecondsSinceEpoch(
          forecast!.city.sunset * 1000,
          isUtc: true,
        ).toLocal();
    final formatter = DateFormat('HH:mm');

    // Intervalle de 1 jour + 3 heures
    final DateTime now = DateTime.now();
    final List<DailySummary> intervalForecasts = [];

    // +3h à partir de maintenant
    int nextHour = ((now.hour + 3) ~/ 3) * 3;
    if (nextHour >= 24) nextHour = nextHour - 24;

    DateTime currentTargetTime = DateTime(
      now.year,
      now.month,
      now.day,
      nextHour,
    );
    if (currentTargetTime.isBefore(now)) {
      currentTargetTime = currentTargetTime.add(const Duration(days: 1));
    }

    for (int i = 0; i < 5; i++) {
      // Prévision la plus proche
      Forecast? closestForecast;
      Duration closestDifference = const Duration(hours: 24);

      for (var f in forecast!.forecasts) {
        final forecastTime =
            DateTime.fromMillisecondsSinceEpoch(
              f.dt * 1000,
              isUtc: true,
            ).toLocal();
        final difference = forecastTime.difference(currentTargetTime).abs();

        if (difference < closestDifference) {
          closestDifference = difference;
          closestForecast = f;
        }
      }

      if (closestForecast != null) {
        final forecastTime =
            DateTime.fromMillisecondsSinceEpoch(
              closestForecast.dt * 1000,
              isUtc: true,
            ).toLocal();
        intervalForecasts.add(
          DailySummary(
            date: forecastTime,
            minTemp: kelvinToCelsius(closestForecast.main.tempMin),
            maxTemp: kelvinToCelsius(closestForecast.main.tempMax),
            icon: closestForecast.weather[0].icon,
            description: closestForecast.weather[0].description,
          ),
        );
      }

      // 1 jour + 3 heures
      currentTargetTime = currentTargetTime.add(
        const Duration(days: 1, hours: 3),
      );
    }

    final List<DailySummary> forecastsToShow = intervalForecasts;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: getGradientColors(isDark),
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => themeProvider.toggleTheme(),
                          icon: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateTime.now().toString().split(' ')[0],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Nom de la ville
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      forecast!.city.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    description.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                  // Icône
                  Image.network(
                    getWeatherIcon(icon),
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: MediaQuery.of(context).size.width * 0.25,
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                  // Température principale
                  Text(
                    '${tempCelsius.toStringAsFixed(0)}°',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.25,
                      fontWeight: FontWeight.w100,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed:
                        () => openMap(
                          forecast!.city.coord.lat,
                          forecast!.city.coord.lon,
                        ),
                    icon: const Icon(Icons.map),
                    label: const Text('Voir sur Google Maps'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                  // Prévisions
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: forecastsToShow.length,
                      itemBuilder: (context, index) {
                        final dailySummary = forecastsToShow[index];
                        String dayName;
                        String timeDisplay;

                        final List<String> days = [
                          'LUN',
                          'MAR',
                          'MER',
                          'JEU',
                          'VEN',
                          'SAM',
                          'DIM',
                        ];
                        dayName = days[dailySummary.date.weekday - 1];

                        timeDisplay = DateFormat(
                          'HH:mm',
                        ).format(dailySummary.date);

                        return Container(
                          width: 85,
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(
                                isDark ? 0.1 : 0.2,
                              ),
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dayName,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                timeDisplay,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Image.network(
                                getWeatherIcon(dailySummary.icon),
                                width: 36,
                                height: 36,
                              ),
                              const SizedBox(height: 8),
                              Column(
                                children: [
                                  Text(
                                    '${dailySummary.maxTemp.toStringAsFixed(0)}°',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      height: 1.1,
                                    ),
                                  ),
                                  Text(
                                    'min ${dailySummary.minTemp.toStringAsFixed(0)}°',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w300,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const Spacer(),

                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(isDark ? 0.15 : 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailItem(
                          'Vent',
                          '${forecast!.forecasts.first.wind.speed.toStringAsFixed(1)} m/s',
                        ),
                        _buildDetailItem('Lever', formatter.format(sunrise)),
                        _buildDetailItem('Coucher', formatter.format(sunset)),
                        _buildDetailItem(
                          'Humidité',
                          '${forecast!.forecasts.first.main.humidity}%',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class DailySummary {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String icon;
  final String description;

  DailySummary({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.icon,
    required this.description,
  });
}
