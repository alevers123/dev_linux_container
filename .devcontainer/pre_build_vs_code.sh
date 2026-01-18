#!/bin/bash

# Pfade definieren (relativ zum .devcontainer Ordner)
STATIC_ENV="static.env"
TARGET_ENV=".env"

echo "Bereite Umgebungsvariablen vor..."

# 1. Starten der .env Datei mit den statischen Werten
if [ -f "$STATIC_ENV" ]; then
    cp "$STATIC_ENV" "$TARGET_ENV"
    echo "✓ Statische Variablen aus $STATIC_ENV kopiert."
else
    echo "# Generierte .env Datei" > "$TARGET_ENV"
    echo "! Warnung: $STATIC_ENV nicht gefunden, erstelle leere .env."
fi

# 2. Dynamische Host-IDs ermitteln
USER_UID=$(id -u)
USER_GID=$(id -g)

# 3. IDs an die .env Datei anhängen
{
    echo ""
    echo "# Automatisch generierte Host-IDs"
    echo "uid=$USER_UID"
    echo "gid=$USER_GID"
} >> "$TARGET_ENV"

echo "✓ Dynamische IDs hinzugefügt: UID=$USER_UID, GID=$USER_GID"
echo "✓ Zieldatei $TARGET_ENV ist bereit."