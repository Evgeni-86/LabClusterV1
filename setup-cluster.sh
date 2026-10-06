#!/bin/bash

echo "========================================="
echo "Запуск полной настройки test-prod-cluster"
echo "========================================="

# Создаем сеть
echo "Создание сети test-prod-net..."
docker network create test-prod-net
sleep 5

# Создаём постоянный volume, который будут использовать все агенты
echo "Создание volume который будут использовать все агенты..."
docker volume create build-workspace
# Даём полные права на запись в volume (чтобы jenkins мог писать)
docker run --rm -v build-workspace:/workspace alpine sh -c "chmod 777 /workspace"
sleep 5

# Создаём volumes для кэша
echo "Создание volume для кеша Maven..."
docker volume create maven-cache
# Даём полные права на запись в volume (Maven будет писать сюда)
docker run --rm -v maven-cache:/maven-cache alpine sh -c "chmod 777 /maven-cache"
sleep 5

# Создание кластера k3d
echo "Создание кластера test-prod-cluster..."
k3d cluster create test-prod-cluster \
  --network test-prod-net \
  --api-port 6550 \
  -p "8081:80@loadbalancer" \
  -p "8443:443@loadbalancer" \
  --agents 1 \
  --registry-config registries.yaml

echo "Кластер создан. Ожидание 60 секунд..."
sleep 60

# Замена URL в kubeconfig
echo "Обновление kubeconfig..."
KUBECONFIG_PATH="$HOME/.kube/config"
sed -i 's|https://host\.docker\.internal:6550|https://localhost:6550|g' "$KUBECONFIG_PATH"

# Установка Argo CD
echo "Добавление репозитория Argo CD..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
echo "Установка Argo CD..."
kubectl create namespace argocd
helm install argocd argo/argo-cd -n argocd
echo "Установка ArgoCD завершена. Ожидание 60 секунд..."
sleep 60

# Запуск Docker Compose
echo "Запуск Docker Compose..."
docker compose up -d
echo "Запуск Docker Compose завершен. Ожидание 30 секунд..."
sleep 30

# Применение Application
echo "Применение Application..."
kubectl apply -f application.yaml
echo "Применение Application завершено. Ожидание 20 секунд..."
sleep 20

# Сборка и пуш образа Jenkins агента
echo "Сборка образа Jenkins агента..."
docker build -f Dockerfile.agent -t localhost:5000/jenkins-agent:docker .
docker push localhost:5000/jenkins-agent:docker

# Пуш Maven образа в registry
echo "Пуш Maven образа в registry..."
docker tag maven:3.9.14-eclipse-temurin-21 localhost:5000/maven:3.9.14-eclipse-temurin-21
docker push localhost:5000/maven:3.9.14-eclipse-temurin-21

# Пуш eclipse-temurin образа в registry
echo "Пуш eclipse-temurin образа в registry..."
docker tag eclipse-temurin:21.0.10_7-jdk-jammy localhost:5000/eclipse-temurin:21.0.10_7-jdk-jammy
docker push localhost:5000/eclipse-temurin:21.0.10_7-jdk-jammy

# Пуш Kanico образа в registry
echo "Пуш Kanico образа в registry..."
docker tag gcr.io/kaniko-project/executor:v1.24.0 localhost:5000/kaniko:v1.24.0
docker push localhost:5000/kaniko:v1.24.0

echo "========================================="
echo "Настройка завершена!"
echo "========================================="
echo "Gitea: http://localhost:3000"
echo "Jenkins: http://localhost:8082"
echo "Argo CD: kubectl get pods -n argocd"