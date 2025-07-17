#!/bin/bash

echo "Regenerating ObjectBox model..."
flutter pub run build_runner build --delete-conflicting-outputs
echo "Done!"
