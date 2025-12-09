# Monitoring Kafka avec Prometheus et Grafana

Ce projet configure un cluster Kafka (KRaft mode) avec 3 brokers et un système de monitoring complet utilisant Prometheus et Grafana, basé sur le repository officiel [confluentinc/jmx-monitoring-stacks](https://github.com/confluentinc/jmx-monitoring-stacks).

## 🏗️ Architecture

- **3 Kafka Brokers** (mode KRaft) avec JMX Exporter intégré
- **Prometheus** pour collecter les métriques
- **Grafana** pour visualiser les dashboards
- **Kafka UI** pour gérer les topics et consumers

## 📋 Prérequis

- Docker et Docker Compose installés
- Au moins 8 GB de RAM alloués à Docker
- Ports disponibles: 3000, 8080-8082, 8888, 9090-9093, 29091-29093

## 🚀 Installation

### 1. Cloner ou créer les fichiers de configuration

Assurez-vous d'avoir les fichiers suivants dans votre répertoire:
- `docker-compose.yml`
- `prometheus.yml`
- `grafana-datasources.yml`
- `grafana-dashboards.yml`
- `jmx-exporter/kafka-broker.yml`

### 2. Exécuter le script de configuration

```bash
chmod +x setup.sh
./setup.sh
```

Ce script va:
- Télécharger le JMX Exporter Java Agent
- Télécharger les dashboards Grafana officiels de Confluent
- Vérifier la présence de tous les fichiers nécessaires

### 3. Démarrer l'environnement

```bash
docker-compose up -d
```

### 4. Vérifier le démarrage

```bash
# Vérifier les conteneurs
docker-compose ps

# Vérifier les logs Kafka
docker-compose logs -f kafka-1

# Vérifier les logs Prometheus
docker-compose logs -f prometheus
```

## 🔗 Accès aux interfaces

| Service | URL | Identifiants |
|---------|-----|--------------|
| Grafana | http://localhost:3000 | admin / admin |
| Prometheus | http://localhost:9090 | - |
| Kafka UI | http://localhost:8888 | - |
| JMX Exporter Kafka-1 | http://localhost:8080/metrics | - |
| JMX Exporter Kafka-2 | http://localhost:8081/metrics | - |
| JMX Exporter Kafka-3 | http://localhost:8082/metrics | - |

## 📊 Dashboards Grafana

Les dashboards suivants sont automatiquement importés:
- **Kafka Overview**: Vue d'ensemble du cluster
- **Kafka Topics**: Métriques par topic
- **Kafka Cluster**: Métriques détaillées du cluster

### Importer manuellement un dashboard

1. Aller sur http://localhost:3000
2. Se connecter (admin/admin)
3. Aller dans **Dashboards** → **Import**
4. Sélectionner un fichier JSON du dossier `dashboards/`

## 🔍 Vérification des métriques

### Vérifier que Prometheus collecte les métriques

1. Aller sur http://localhost:9090
2. Aller dans **Status** → **Targets**
3. Vérifier que les 3 targets Kafka sont "UP"

### Requêtes Prometheus utiles

```promql
# Nombre de messages par seconde
rate(kafka_server_brokertopicmetrics_messagesin_total[5m])

# Partitions sous-répliquées
kafka_server_replicamanager_underreplicatedpartitions

# Utilisation CPU des Request Handlers
100 - (kafka_server_kafkarequesthandlerpool_requesthandleravgidlepercent * 100)

# Leader du cluster
kafka_controller_kafkacontroller_activecontrollercount
```

## 🧪 Tester avec des données

### Créer un topic

```bash
docker exec -it kafka-1 kafka-topics \
  --bootstrap-server kafka-1:29091 \
  --create \
  --topic test-topic \
  --partitions 3 \
  --replication-factor 3
```

### Produire des messages

```bash
docker exec -it kafka-1 kafka-console-producer \
  --bootstrap-server kafka-1:29091 \
  --topic test-topic
```

### Consommer des messages

```bash
docker exec -it kafka-1 kafka-console-consumer \
  --bootstrap-server kafka-1:29091 \
  --topic test-topic \
  --from-beginning
```

### Générer de la charge

```bash
# Script de production en boucle
for i in {1..1000}; do 
  echo "Message $i" | docker exec -i kafka-1 kafka-console-producer \
    --bootstrap-server kafka-1:29091 \
    --topic test-topic
  sleep 0.1
done
```

## 🔧 Configuration avancée

### Modifier la configuration JMX Exporter

Éditez `jmx-exporter/kafka-broker.yml` pour:
- Ajouter/supprimer des patterns de métriques
- Modifier les noms des métriques exportées
- Filtrer les métriques par topic ou partition

Après modification:
```bash
docker-compose restart kafka-1 kafka-2 kafka-3
```

### Modifier la configuration Prometheus

Éditez `prometheus.yml` pour:
- Ajuster l'intervalle de scraping
- Ajouter d'autres targets
- Configurer des alertes

Après modification:
```bash
docker-compose restart prometheus
```

## 📝 Principales différences avec votre configuration initiale

1. **Suppression du conteneur JMX Exporter séparé**: Le JMX Exporter est maintenant intégré directement dans les brokers Kafka via `KAFKA_OPTS`

2. **Configuration KAFKA_OPTS**: Ajout de la variable d'environnement qui charge le Java Agent JMX Exporter au démarrage de Kafka

3. **Ports JMX Exporter**: Chaque broker expose les métriques Prometheus sur un port dédié (8080, 8081, 8082)

4. **Volume monté**: Le dossier `jmx-exporter/` contenant le JAR et la configuration est monté dans chaque conteneur Kafka

5. **Configuration Prometheus simplifiée**: Prometheus scrape directement les endpoints HTTP des JMX Exporters intégrés

## 🐛 Dépannage

### Les métriques n'apparaissent pas dans Prometheus

```bash
# Vérifier que JMX Exporter fonctionne
curl http://localhost:8080/metrics

# Vérifier les logs Kafka
docker-compose logs kafka-1 | grep -i jmx

# Vérifier la configuration Prometheus
docker exec prometheus cat /etc/prometheus/prometheus.yml
```

### Les dashboards Grafana sont vides

1. Vérifier que Prometheus collecte les données (Status → Targets)
2. Vérifier que la datasource Prometheus est configurée
3. Attendre quelques minutes pour que les métriques s'accumulent

### Kafka ne démarre pas

```bash
# Vérifier les logs
docker-compose logs kafka-1

# Vérifier que le fichier JMX Exporter existe
docker exec kafka-1 ls -la /usr/share/jmx-exporter/

# Redémarrer avec logs
docker-compose up kafka-1
```

## 🧹 Nettoyage

```bash
# Arrêter tous les conteneurs
docker-compose down

# Supprimer également les volumes (ATTENTION: perte de données)
docker-compose down -v

# Supprimer les images
docker-compose down --rmi all
```

## 📚 Ressources

- [Documentation Confluent - JMX Monitoring](https://docs.confluent.io/platform/current/installation/docker/operations/monitoring.html)
- [JMX Monitoring Stacks Repository](https://github.com/confluentinc/jmx-monitoring-stacks)
- [Prometheus JMX Exporter](https://github.com/prometheus/jmx_exporter)
- [Blog Confluent - Monitor Kafka with Prometheus](https://www.confluent.io/blog/monitor-kafka-clusters-with-prometheus-grafana-and-confluent/)

## ⚠️ Notes de production

Cette configuration est destinée au **développement et aux tests**. Pour la production:

1. Activez l'authentification JMX
2. Utilisez SSL/TLS pour les connexions
3. Configurez la rétention des métriques Prometheus
4. Mettez en place des alertes
5. Sécurisez les accès Grafana
6. Utilisez des volumes persistants externes
7. Ajustez les ressources (mémoire, CPU)

## 📄 Licence

Ce projet utilise des composants open source. Consultez les licences respectives:
- Apache Kafka: Apache License 2.0
- Prometheus: Apache License 2.0
- Grafana: AGPL License
