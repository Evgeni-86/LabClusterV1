#!/bin/bash

echo "Установка k3d и Helm..."
winget install k3d
winget install Helm.Helm

echo "Загрузка Docker образов..."
docker pull registry:3
docker pull gitea/gitea:1.25
docker pull jenkins/jenkins:2.554
docker pull maven:3.9.14-eclipse-temurin-21
docker pull eclipse-temurin:21.0.10_7-jdk-jammy
docker pull jenkins/inbound-agent:jdk21
docker pull gcr.io/kaniko-project/executor:v1.24.0

echo "Создание тегов для локального registry..."
docker tag maven:3.9.14-eclipse-temurin-21 localhost:5000/maven:3.9.14-eclipse-temurin-21
docker tag eclipse-temurin:21.0.10_7-jdk-jammy localhost:5000/eclipse-temurin:21.0.10_7-jdk-jammy
docker tag gcr.io/kaniko-project/executor:v1.24.0 localhost:5000/kaniko:v1.24.0

echo "Проверка загруженных образов:"
docker images | grep -E "registry|gitea|jenkins|maven|eclipse-temurin"