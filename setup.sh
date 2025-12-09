#!/bin/bash

set -e

echo "==================================================="
echo "Configuration du monitoring Kafka avec Prometheus et Grafana"
echo "==================================================="

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Création des répertoires nécessaires
echo -e "${YELLOW}Création des répertoires...${NC}"
mkdir -p jmx-exporter
mkdir -p dashboards

# Téléchargement du JMX Exporter Java Agent
JMX_EXPORTER_VERSION="1.0.1"
JMX_EXPORTER_JAR="jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar"

if [ ! -f "jmx-exporter/${JMX_EXPORTER_JAR}" ]; then
    echo -e "${YELLOW}Téléchargement du JMX Exporter ${JMX_EXPORTER_VERSION}...${NC}"
    curl -L -o "jmx-exporter/jmx_prometheus_javaagent.jar" \
        "https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_EXPORTER_VERSION}/${JMX_EXPORTER_JAR}"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}JMX Exporter téléchargé avec succès${NC}"
    else
        echo -e "${RED}Erreur lors du téléchargement du JMX Exporter${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}JMX Exporter déjà présent${NC}"
fi

# Téléchargement des dashboards Grafana officiels de Confluent
echo -e "${YELLOW}Téléchargement des dashboards Grafana...${NC}"

DASHBOARDS=(
    "kafka-overview.json:https://raw.githubusercontent.com/confluentinc/jmx-monitoring-stacks/main/jmxexporter-prometheus-grafana/assets/grafana/provisioning/dashboards/kafka-overview.json"
    "kafka-topics.json:https://raw.githubusercontent.com/confluentinc/jmx-monitoring-stacks/main/jmxexporter-prometheus-grafana/assets/grafana/provisioning/dashboards/kafka-topics.json"
    "kafka-cluster.json:https://raw.githubusercontent.com/confluentinc/jmx-monitoring-stacks/main/jmxexporter-prometheus-grafana/assets/grafana/provisioning/dashboards/kafka-cluster.json"
)

for dashboard in "${DASHBOARDS[@]}"; do
    IFS=':' read -r filename url <<< "$dashboard"
    
    if [ ! -f "dashboards/${filename}" ]; then
        echo -e "${YELLOW}Téléchargement de ${filename}...${NC}"
        curl -L -o "dashboards/${filename}" "${url}" || echo -e "${RED}Erreur pour ${filename}${NC}"
    else
        echo -e "${GREEN}${filename} déjà présent${NC}"
    fi
done

# Vérification des fichiers de configuration
echo -e "${YELLOW}Vérification des fichiers de configuration...${NC}"

required_files=(
    "docker-compose.yml"
    "prometheus.yml"
    "grafana-datasources.yml"
    "grafana-dashboards.yml"
    "jmx-exporter/kafka-broker.yml"
)

missing_files=0
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}Fichier manquant: $file${NC}"
        missing_files=$((missing_files + 1))
    else
        echo -e "${GREEN}✓ $file${NC}"
    fi
done

if [ $missing_files -gt 0 ]; then
    echo -e "${RED}${missing_files} fichier(s) manquant(s). Veuillez créer les fichiers manquants.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}==================================================="
echo "Configuration terminée avec succès!"
echo "===================================================${NC}"
echo ""
echo "Pour démarrer l'environnement, exécutez:"
echo -e "${YELLOW}docker-compose up -d${NC}"
echo ""
echo "Accès aux interfaces:"
echo "  - Grafana:     http://localhost:3000 (admin/admin)"
echo "  - Prometheus:  http://localhost:9090"
echo "  - Kafka UI:    http://localhost:8888"
echo ""
echo "Pour vérifier les métriques JMX Exporter:"
echo "  - Kafka-1: http://localhost:8080/metrics"
echo "  - Kafka-2: http://localhost:8081/metrics"
echo "  - Kafka-3: http://localhost:8082/metrics"
echo ""
