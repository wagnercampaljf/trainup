#!/usr/bin/env bash
# Executa o Flutter dentro do Docker em máquinas sem Flutter/Android SDK
# (ex.: Windows com Docker Desktop, via Git Bash).
#
# - Imagem: ghcr.io/cirruslabs/flutter:stable (traz Android SDK e Java).
# - SDK: Flutter 3.47.6 no volume `trainup-flutter-sdk` (mesma versão do
#   projeto; a tag da imagem acompanha a última estável).
# - Caches de pub, Gradle e Android SDK (plataformas/NDK/CMake que o build
#   instala) em volumes, para não baixar tudo a cada execução.
#
# Uso: tool/docker_flutter.sh [argumentos do flutter]   (padrão: test)
#      tool/docker_flutter.sh --shell 'comando bash'   (ex.: dart run ...)
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd -W 2>/dev/null || pwd)"
IMAGE="${FLUTTER_TEST_IMAGE:-ghcr.io/cirruslabs/flutter:stable}"
SDK=/sdk/flutter

if ! docker volume inspect trainup-flutter-sdk >/dev/null 2>&1; then
  echo "Baixando o Flutter 3.47.6 para o volume trainup-flutter-sdk..." >&2
  docker run --rm -v trainup-flutter-sdk:/sdk alpine sh -c \
    'apk add --no-cache curl xz tar >/dev/null && curl -sL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.6-stable.tar.xz | tar -xJ -C /sdk'
fi

if [ "${1:-}" = "--shell" ]; then
  shift
  CMD="$*"
else
  [ "$#" -eq 0 ] && set -- test
  CMD="flutter $(printf '%q ' "$@")"
fi

MSYS_NO_PATHCONV=1 exec docker run --rm \
  -e FLUTTER_SUPPRESS_ANALYTICS=true \
  -e PUB_CACHE=/pub-cache \
  -e GRADLE_USER_HOME=/gradle \
  -v trainup-flutter-sdk:/sdk \
  -v trainup-pub-cache:/pub-cache \
  -v trainup-gradle:/gradle \
  -v trainup-android-sdk:/opt/android-sdk-linux \
  -v "$PROJECT_DIR:/work" \
  -w /work \
  "$IMAGE" \
  bash -c "git config --global --add safe.directory '*' && export PATH=$SDK/bin:\$PATH && $CMD"
