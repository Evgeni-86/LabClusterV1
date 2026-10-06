#!/bin/sh

echo "=== Удаление Argo CD ==="
# Удаление Argo CD (если установлен)
helm uninstall argocd -n argocd 2>/dev/null || echo "Argo CD не найден или уже удален"
# Удаление namespace Argo CD
kubectl delete namespace argocd 2>/dev/null || echo "Namespace argocd не найден"

echo "=== Удаление репозитория Helm ==="
# Удаление репозитория Argo CD из Helm
helm repo remove argo 2>/dev/null || echo "Репозиторий argo не найден"

echo "=== Удаление Helm ==="
# Удаление Helm через winget
winget uninstall Helm.Helm 2>/dev/null || echo "Helm не найден"

echo "=== Удаление k3d ==="
# Удаление всех кластеров k3d
k3d cluster delete --all 2>/dev/null || echo "Нет кластеров k3d для удаления"
# Удаление k3d через winget
winget uninstall k3d 2>/dev/null || echo "k3d не найден"

echo "=== Очистка конфигурации kubectl ==="
# Очистка контекста kubectl (опционально)
kubectl config unset current-context 2>/dev/null || echo "Контекст не установлен"
kubectl config delete-cluster k3d-* 2>/dev/null || echo "Кластеры k3d не найдены в конфиге"
kubectl config delete-context k3d-* 2>/dev/null || echo "Контексты k3d не найдены"

echo "=== Откат завершен ==="