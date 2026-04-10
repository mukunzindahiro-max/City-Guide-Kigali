# Kigali City Guide

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Riverpod](https://img.shields.io/badge/Riverpod-0553B1?style=for-the-badge&logo=dart&logoColor=white)

A mobile city guide application for discovering and sharing places in Kigali, Rwanda. Users can browse categorized listings (hospitals, restaurants, parks, tourist attractions, and more), view them on an interactive map, and contribute their own places to the community.

## Features

- **User Authentication** — Email/password sign-up and login with Firebase Auth, email verification, and password reset
- **Onboarding** — Welcome slides for first-time users with SharedPreferences persistence
- **Directory** — Searchable, filterable listing of all places organized by category
- **Interactive Map** — OpenStreetMap-powered map view with markers and popup cards for each listing
- **Listing Details** — Full place info with map preview, tap-to-call, and directions via url_launcher
- **Add / Edit Listings** — Form with category dropdown, address, contact, description, and map-based lat/lng picker
- **My Listings** — View, edit, and delete your own contributed places
- **Settings** — Sign out and app information
- **Real-time Sync** — Firestore streams keep the UI up to date across devices instantly

## Tech Stack

| Layer              | Technology                        |
|--------------------|-----------------------------------|
| Framework          | Flutter (Dart SDK ^3.10.7)        |
| Authentication     | Firebase Auth                     |
| Database           | Cloud Firestore                   |
| State Management   | Flutter Riverpod                  |
| Maps               | flutter_map + OpenStreetMap tiles  |
| Geolocation Types  | latlong2                          |
| External Links     | url_launcher                      |
| Local Storage      | shared_preferences                |

## screens
<p align="center">
  <img width="200" src="https://github.com/user-attachments/assets/b84bce93-f9eb-4b53-8499-f963172bd931" />
  <img width="200" src="https://github.com/user-attachments/assets/3fdf69f8-f8aa-48e7-b3df-00f8dfff37fc" />
  <img width="200" src="https://github.com/user-attachments/assets/5b5f2416-f9db-40b8-89de-49e6d6ba4d84" />
  <img width="200" src="https://github.com/user-attachments/assets/084cb983-1c43-4339-bfd0-5e78030489f1" />
  <img width="200" src="https://github.com/user-attachments/assets/ec38b566-2d8c-4f9a-8a63-1acb2f7d0d41" />
</p>
<p align="center">
  <img width="200" src="https://github.com/user-attachments/assets/9785e5ec-9e4b-4099-947f-28d65be441c5" />
  <img width="200" src="https://github.com/user-attachments/assets/7455ed9a-e425-45e1-be89-d66e84932651" />
  <img width="200" src="https://github.com/user-attachments/assets/7cf189e9-e790-47b9-b530-bd809ed5e7c6" />
  <img width="200" src="https://github.com/user-attachments/assets/a2e1cb61-47d6-4456-97a4-6166ac5c1061" />
</p>

## Project Structure

```
lib/
├── main.dart                  # App entry point, theme, auth routing
├── firebase_options.dart      # Generated Firebase config
├── models/
│   └── listing.dart           # Listing data model + categories
├── providers/
│   └── providers.dart         # Riverpod providers (auth, listings)
├── services/
│   ├── auth_service.dart      # Firebase Auth wrapper
│   └── listing_service.dart   # Firestore CRUD for listings
└── screens/
    ├── onboarding_screen.dart
    ├── login_screen.dart
    ├── signup_screen.dart
    ├── email_verification_screen.dart
    ├── home_screen.dart
    ├── directory_screen.dart
    ├── map_view_screen.dart
    ├── listing_detail_screen.dart
    ├── add_edit_listing_screen.dart
    ├── my_listings_screen.dart
    └── settings_screen.dart
```

## Getting Started

### Prerequisites

- Flutter SDK (^3.10.7)
- A Firebase project with Auth and Firestore enabled

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/mukunzindahiro-max/City-Guide-Kigali
   cd city_guide_kigali
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase (if not already done):
   ```bash
   flutterfire configure
   ```

4. Run the app:
   ```bash
   flutter run
   ```
