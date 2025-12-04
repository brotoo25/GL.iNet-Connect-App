# GL.iNet Repeater Setup App

A Flutter application for configuring GL.iNet router (GL-BE3600, firmware 4.8.1) repeater WiFi credentials via JSON-RPC API.

## Features

- WiFi network scanning
- Secure credential storage
- Repeater configuration

## Prerequisites

- Flutter SDK 3.0+
- GL.iNet router at 192.168.8.1

## Setup Instructions

1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Run `flutter run` to start the app.

## Dependencies

- `http`: For JSON-RPC API communication
- `flutter_secure_storage`: For secure credential storage
- `permission_handler`: For runtime permissions

## Architecture

This app uses Material Design 3 and is designed as a single-screen application.