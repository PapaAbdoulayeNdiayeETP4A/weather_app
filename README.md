# Weather App 🌦️

Project developed for the Mobile Development Exam L3 DAR/ESMT 2025  
**Authors:** Papa Abdoulaye Ndiaye, Mouhamed Abdoulaye Ndoye

---

## Overview

Weather App is a Flutter application that lets you explore real-time weather for multiple cities, with a modern design, smooth navigation, and an interactive experience.  
Here’s a detailed description of each screen, based on the actual code and features:

---

## 🏠 Home Screen

- **Design & Welcome:** A dynamic gradient background (blue or grey depending on the theme) and a central icon (sun/moon) welcome the user. The title “Météo Explorer” appears in large text.
- **City Search:** A search field lets you enter a city name. Submitting a valid city opens the details page for that city. Errors (empty field, short name) are shown with animated feedback.
- **Quick Search Button:** The “Rechercher” button launches the search, with a loading animation if needed.
- **Random Exploration:** The “Exploration aléatoire” button lets you discover the weather for 5 randomly selected cities (taking you to the main screen).
- **Feature Highlights (on desktop/tablet):** Cards showcase key features: personalized search, real-time temperatures, detailed humidity, and more.
- **Light/Dark theme:** A button in the top right allows instant switching between light and dark mode.

---

## 📊 Main Screen (Random Exploration)

- **Animated Progress:** When entering, a progress bar animates as weather data is fetched for 5 random cities.
- **Dynamic Messages:** Various loading messages are displayed (“Nous téléchargeons les données...”, “C’est presque fini...”, etc.).
- **Results Display:** Once loading is complete, an interactive list shows the 5 cities: temperature, weather, humidity, wind, etc. Each card is color-coded according to temperature (blue, green, orange, red, etc.).
- **Detail Navigation:** The user can tap a city to view detailed info (navigates to the city detail page).
- **Replayability:** A “Recommencer” button lets you start another random exploration.
- **Error Handling:** If an API error occurs, a stylish error message appears with an option to retry.
- **Dynamic Theme:** All UI elements adapt to the light/dark theme.

---

## 📍 City Details Page

- **Detailed Display:** Shows city name, weather icon, description, main temperature, humidity, sunrise/sunset times, etc.
- **Hourly Forecasts:** Horizontal list of forecasts for the next 24h/3h.
- **Google Maps:** A “Voir sur Google Maps” button opens the city location in Google Maps.
- **Simple Back:** A back button returns to the previous screen.
- **Error & Loading Handling:** Shows a loading indicator or error message with a “Réessayer” button if needed.
- **Light/Dark theme:** The page adapts instantly to the selected theme.

---

## 🌗 Theme Handling & Navigation

- **Theme Switching:** On every screen, a dedicated button allows smooth, instant switching (using a global provider).
- **Navigation:** Navigation between screens uses Navigator with animated transitions:
    - Search → City Details
    - Home → Exploration → City Details
    - Back is always available
- **Provider:** The theme is shared app-wide via the `ThemeProvider`.

---

## 📦 Main Dependencies

| Package             | Description                                                                 |
|---------------------|-----------------------------------------------------------------------------|
| **flutter**         | The main SDK for building cross-platform mobile apps.                        |
| **provider**        | State management; used for sharing theme and app state across the app.       |
| **dio**             | Powerful HTTP client used for making API requests (weather data).            |
| **intl**            | For formatting dates/times (e.g., sunrise/sunset, forecast times).           |
| **url_launcher**    | Opens external links, e.g., launching Google Maps for city localization.     |
| **animations**      | Used for smooth transitions and animated widgets throughout the UI.          |

> _These dependencies enable API access, smooth UI, proper state management, and integration with external services like Google Maps._

---

## 🚀 Running the App

```bash
git clone git@github.com:PapaAbdoulayeNdiayeETP4A/weather_app.git
cd weather_app
flutter pub get
flutter run
```

---

## 👥 Authors

- Papa Abdoulaye Ndiaye
- Mouhamed Abdoulaye Ndoye

---

This app is designed to provide a modern, accessible, and enjoyable experience, fully matching the exam requirements.  
🔥 Enjoy your weather exploration! 🔥