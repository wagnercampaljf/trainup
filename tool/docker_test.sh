#!/usr/bin/env bash
# Executa comandos Flutter dentro de um container Linux recente.
#
# Necessário apenas em hosts com glibc < 2.33 (ex.: Ubuntu 20.04), onde a
# biblioteca SQLite pré-compilada pelo pacote `sqlite3` não carrega nos
# testes. Usa o mesmo Flutter SDK e pub-cache do host.
#
# Uso: tool/docker_test.sh [argumentos do flutter]   (padrão: test)
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FLUTTER_ROOT="${FLUTTER_ROOT:-$(dirname "$(dirname "$(readlink -f "$(command -v flutter)")")")}"
PUB_CACHE_DIR="${PUB_CACHE:-$HOME/.pub-cache}"
IMAGE="${FLUTTER_TEST_IMAGE:-ghcr.io/cirruslabs/flutter:stable}"

if [ "$#" -eq 0 ]; then
  set -- test
fi

exec docker run --rm \
  -u "$(id -u):$(id -g)" \
  -e HOME=/tmp/home \
  -e PUB_CACHE="$PUB_CACHE_DIR" \
  -e FLUTTER_SUPPRESS_ANALYTICS=true \
  -v "$FLUTTER_ROOT:$FLUTTER_ROOT" \
  -v "$PUB_CACHE_DIR:$PUB_CACHE_DIR" \
  -v "$PROJECT_DIR:$PROJECT_DIR" \
  -w "$PROJECT_DIR" \
  "$IMAGE" \
  bash -c 'mkdir -p "$HOME" && git config --global --add safe.directory "*" && exec "$0"/bin/flutter "$@"' \
  "$FLUTTER_ROOT" "$@"
