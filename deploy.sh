#!/bin/bash

# Variables (à adapter)
GIT_REPO="https://gitlab.com/ghassenjeddou3/django_automation.git"
LOCAL_DIR="django_automation"
DOCKER_IMAGE="registry.gitlab.com/ghassenjeddou3/django_automation:latest"
CONTAINER_NAME="django_test_container"
LOCAL_PORT=${1:-8000}  # port local par défaut 8000, modifiable via argument

echo "1. Clonage du projet"

if [ -d "$LOCAL_DIR" ]; then
  echo "Suppression du dossier $LOCAL_DIR existant..."
  rm -rf "$LOCAL_DIR"
fi

git clone "$GIT_REPO" "$LOCAL_DIR" || { echo "Erreur lors du clone du dépôt"; exit 1; }

echo "2. Pull de l'image Docker"
docker pull "$DOCKER_IMAGE" || { echo "Erreur lors du pull de l'image Docker"; exit 1; }

echo "3. Arrêt et suppression du conteneur précédent (s'il existe)..."
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

echo "4. Lancement du conteneur en arrière-plan sur le port $LOCAL_PORT..."
docker run -d --name "$CONTAINER_NAME" -p "$LOCAL_PORT":8000 "$DOCKER_IMAGE" || { echo "Erreur au démarrage du conteneur"; exit 1; }

echo "5. Attente du démarrage de l'application..."

# Timeout après 30 secondes max
MAX_WAIT=30
WAITED=0
while ! curl -s --head "http://localhost:$LOCAL_PORT" | grep "200 OK" > /dev/null; do
  sleep 2
  WAITED=$((WAITED + 2))
  if [ $WAITED -ge $MAX_WAIT ]; then
    echo "Erreur : l'application ne répond pas après $MAX_WAIT secondes."
    echo "Logs du conteneur :"
    docker logs "$CONTAINER_NAME"
    exit 1
  fi
done

echo "Déploiement réussi : l'application est accessible sur http://localhost:$LOCAL_PORT"

echo "Script terminé avec succès."


echo "Script terminé avec succès."
