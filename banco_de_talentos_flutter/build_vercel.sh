#!/bin/bash
set -e

# 1. Instala o Flutter SDK se não estiver no PATH (ambiente Vercel)
if ! command -v flutter &> /dev/null; then
  echo "Flutter não encontrado. Baixando Flutter SDK (stable)..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter-sdk
  export PATH="$PATH:$(pwd)/flutter-sdk/bin"
fi

flutter --version

# 2. Gera o arquivo .env com as variáveis configuradas na Vercel
echo "API_URL=$API_URL" > .env
echo "API_KEY=$API_KEY" >> .env

# 3. Instala dependências e roda o gerador de código (Envied/Injectable)
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# 4. Compila para Web
flutter build web --release

