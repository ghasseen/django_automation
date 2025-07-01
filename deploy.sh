#!/bin/bash

# Variables (à adapter)
GIT_REPO="https://gitlab.com/ghassenjeddou3/django_automation.git"
LOCAL_DIR="django_automation"
DOCKER_IMAGE="registry.gitlab.com/ghassenjeddou3/django_automation:latest"
CONTAINER_NAME="django_test_container"

echo "1. Clonage du projet"

# Si le dossier existe déjà, on le supprime pour repartir propre
if [ -d "$LOCAL_DIR" ]; then
  echo "Suppression du dossier $LOCAL_DIR existant"
  rm -rf "$LOCAL_DIR"
fi

git clone "$GIT_REPO" "$LOCAL_DIR" || { echo "Erreur lors du clone"; exit 1; }

echo "2. Pull de l'image Docker"

docker pull "$DOCKER_IMAGE" || { echo "Erreur lors du pull de l'image Docker"; exit 1; }

echo "3. Lancement du conteneur pour test"

# Supprimer le conteneur s'il existe déjà
docker rm -f "$CONTAINER_NAME" 2>/dev/null

# Lancer le conteneur (exemple avec mapping du port 8000)
docker run -d --name "$CONTAINER_NAME" -p 8000:8000 "$DOCKER_IMAGE" || { echo "Erreur au démarrage du conteneur"; exit 1; }

echo "Attente de quelques secondes pour que le serveur démarre..."
sleep 5

# Tester la disponibilité via curl (http://localhost:8000)
if curl -s --head http://localhost:8000 | grep "200 OK" > /dev/null; then
  echo "Déploiement réussi, l'application est accessible sur http://localhost:8000"
else
  echo "Erreur : l'application ne répond pas comme attendu"
  docker logs "$CONTAINER_NAME"
  exit 1
fi

echo "Script terminé avec succès."
