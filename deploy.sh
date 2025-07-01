#!/bin/bash

# Variables
GIT_REPO="https://gitlab.com/ghassenjeddou3/django_automation.git"
LOCAL_DIR="django_automation"
LOCAL_PORT=${1:-8000}  # port local par défaut 8000, modifiable via argument

echo "1. Clonage du projet"

if [ -d "$LOCAL_DIR" ]; then
  echo "Suppression du dossier $LOCAL_DIR existant..."
  rm -rf "$LOCAL_DIR"
fi

git clone "$GIT_REPO" "$LOCAL_DIR" || { echo "Erreur lors du clone du dépôt"; exit 1; }

cd "$LOCAL_DIR" || { echo "Erreur : dossier $LOCAL_DIR non trouvé"; exit 1; }

echo "2. Pull des images Docker (si images dans docker-compose.yml avec image: ...)"

docker-compose pull

echo "3. Arrêt et suppression des conteneurs existants (s'il y en a)..."
docker-compose down

echo "4. Lancement des services avec docker-compose..."
docker-compose up -d

echo "5. Attente du démarrage de l'application..."

MAX_WAIT=60
WAITED=0

while ! curl -s --head "http://localhost:$LOCAL_PORT" | grep "200 OK" > /dev/null; do
  sleep 3
  WAITED=$((WAITED + 3))
  if [ $WAITED -ge $MAX_WAIT ]; then
    echo "Erreur : l'application ne répond pas après $MAX_WAIT secondes."
    echo "Logs du service web :"
    docker-compose logs web
    exit 1
  fi
done

echo "Déploiement réussi : l'application est accessible sur http://localhost:$LOCAL_PORT"

echo "Script terminé avec succès."



