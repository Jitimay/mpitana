#!/bin/bash

# Run flutter pub get to install dependencies
flutter pub get

# Generate native splash screen
dart run flutter_native_splash:create

echo "Splash screen setup completed!"
