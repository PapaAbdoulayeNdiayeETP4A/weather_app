// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForecastResponse _$ForecastResponseFromJson(Map<String, dynamic> json) =>
    ForecastResponse(
      forecasts: (json['list'] as List<dynamic>)
          .map((e) => Forecast.fromJson(e as Map<String, dynamic>))
          .toList(),
      cnt: (json['cnt'] as num).toInt(),
      city: City.fromJson(json['city'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ForecastResponseToJson(ForecastResponse instance) =>
    <String, dynamic>{
      'cnt': instance.cnt,
      'city': instance.city,
      'list': instance.forecasts,
    };

Forecast _$ForecastFromJson(Map<String, dynamic> json) => Forecast(
      dt: (json['dt'] as num).toInt(),
      main: Main.fromJson(json['main'] as Map<String, dynamic>),
      weather: (json['weather'] as List<dynamic>)
          .map((e) => Weather.fromJson(e as Map<String, dynamic>))
          .toList(),
      wind: Wind.fromJson(json['wind'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ForecastToJson(Forecast instance) => <String, dynamic>{
      'dt': instance.dt,
      'main': instance.main,
      'weather': instance.weather,
      'wind': instance.wind,
    };

Main _$MainFromJson(Map<String, dynamic> json) => Main(
      temp: (json['temp'] as num).toDouble(),
      humidity: (json['humidity'] as num).toInt(),
      tempMin: (json['temp_min'] as num).toDouble(),
      tempMax: (json['temp_max'] as num).toDouble(),
    );

Map<String, dynamic> _$MainToJson(Main instance) => <String, dynamic>{
      'temp': instance.temp,
      'temp_min': instance.tempMin,
      'temp_max': instance.tempMax,
      'humidity': instance.humidity,
    };

Weather _$WeatherFromJson(Map<String, dynamic> json) => Weather(
      description: json['description'] as String,
      icon: json['icon'] as String,
    );

Map<String, dynamic> _$WeatherToJson(Weather instance) => <String, dynamic>{
      'description': instance.description,
      'icon': instance.icon,
    };

Wind _$WindFromJson(Map<String, dynamic> json) => Wind(
      speed: (json['speed'] as num).toDouble(),
    );

Map<String, dynamic> _$WindToJson(Wind instance) => <String, dynamic>{
      'speed': instance.speed,
    };

City _$CityFromJson(Map<String, dynamic> json) => City(
      name: json['name'] as String,
      coord: Coord.fromJson(json['coord'] as Map<String, dynamic>),
      sunrise: (json['sunrise'] as num).toInt(),
      sunset: (json['sunset'] as num).toInt(),
    );

Map<String, dynamic> _$CityToJson(City instance) => <String, dynamic>{
      'name': instance.name,
      'sunrise': instance.sunrise,
      'sunset': instance.sunset,
      'coord': instance.coord,
    };

Coord _$CoordFromJson(Map<String, dynamic> json) => Coord(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );

Map<String, dynamic> _$CoordToJson(Coord instance) => <String, dynamic>{
      'lat': instance.lat,
      'lon': instance.lon,
    };
