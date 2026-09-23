#!/bin/bash
set -e

echo "API_URL=$API_URL" > .env
echo "API_KEY=$API_KEY" >> .env


flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

flutter build web --release
