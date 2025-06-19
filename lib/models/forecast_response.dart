import 'package:json_annotation/json_annotation.dart';

part 'forecast_response.g.dart';

@JsonSerializable()
class ForecastResponse {
  final int cnt;
  final City city;
  @JsonKey(name: 'list')
  final List<Forecast> forecasts;

  ForecastResponse({required this.forecasts, required this.cnt, required this.city});

  factory ForecastResponse.fromJson(Map<String, dynamic> json) =>
      _$ForecastResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastResponseToJson(this);
}

@JsonSerializable()
class Forecast {
  final int dt;
  final Main main;
  final List<Weather> weather;
  final Wind wind;

  Forecast({required this.dt, required this.main, required this.weather, required this.wind});

  factory Forecast.fromJson(Map<String, dynamic> json) => _$ForecastFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastToJson(this);
}

@JsonSerializable()
class Main {
  final double temp;
  @JsonKey(name: 'temp_min')
  final double tempMin;
  @JsonKey(name: 'temp_max')
  final double tempMax;
  final int humidity;

  Main({required this.temp, required this.humidity, required this.tempMin, required this.tempMax});

  factory Main.fromJson(Map<String, dynamic> json) => _$MainFromJson(json);
  Map<String, dynamic> toJson() => _$MainToJson(this);
}

@JsonSerializable()
class Weather {
  final String description;
  final String icon;

  Weather({required this.description, required this.icon});

  factory Weather.fromJson(Map<String, dynamic> json) => _$WeatherFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherToJson(this);
}

@JsonSerializable()
class Wind {
  final double speed;

  Wind({required this.speed});

  factory Wind.fromJson(Map<String, dynamic> json) => _$WindFromJson(json);
  Map<String, dynamic> toJson() => _$WindToJson(this);
}

@JsonSerializable()
class City {
  final String name;
  final int sunrise;
  final int sunset;
  final Coord coord;

  City({required this.name, required this.coord, required this.sunrise, required this.sunset});

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);
  Map<String, dynamic> toJson() => _$CityToJson(this);
}

@JsonSerializable()
class Coord {
  final double lat;
  final double lon;

  Coord({required this.lat, required this.lon});

  factory Coord.fromJson(Map<String, dynamic> json) => _$CoordFromJson(json);
  Map<String, dynamic> toJson() => _$CoordToJson(this);
}
