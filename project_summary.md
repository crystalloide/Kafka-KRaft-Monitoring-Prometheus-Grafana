# 📋 Résumé du Projet - Kafka Monitoring avec Prometheus & Grafana

## 🎯 Objectif

Configurer un cluster Kafka (mode KRaft) avec 3 brokers et un système de monitoring complet utilisant:
- **JMX Exporter** (intégré dans Kafka via Java Agent)
- **Prometheus** (collecte des métriques)
- **Grafana** (visualisation)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     KAFKA CLUSTER (KRaft)                   │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────┐      ┌─────────┐      ┌─────────┐            │
│  │ Kafka-1 │      │ Kafka-2 │      │ Kafka-3 │            │
│  │  :29091 │      │  :29092 │      │  :29093 │            │
│  │         │      │         │      │         │            │
│  │ JMX     │      │ JMX     │      │ JMX     │            │
│  │ :8080   │      │ :8081   │      │ :8082   │            │
│  └────┬────┘      └────┬────┘      └────┬────┘            │
└───────┼────────────────┼────────────────┼─────────────────┘
        │                │                │
        └────────────────┼────────────────┘
                         │ (métriques JMX Exporter)
                         ↓
                  ┌──────────────┐
                  │  Prometheus  │
                  │    :9090     │
                  └──────┬───────┘
                         │ (PromQL)
                         ↓
                  ┌──────────────┐
                  │   Grafana    │
                  │    :3000     │
                  └──────────────┘
```

## 📁 Structure du Projet

```
kafka-monitoring/
├── docker-compose.yml              # Configuration Docker Compose
├── prometheus.yml                   # Configuration Prometheus
├── grafana-datasources.yml         # Configuration datasource Grafana
├── grafana-dashboards.yml          # Configuration auto-import dashboards
├── setup.sh                        # Script d'installation
├── Makefile                        # Commandes utiles
├── .gitignore                      # Fichiers à ignorer
│
├── jmx-exporter/                   # Configuration JMX Exporter
│   ├── jmx_prometheus_javaagent.jar  # Java Agent (téléchargé)
│   └── kafka-broker.yml            # Rules JMX → Prometheus
│
├── dashboards/                     # Dashboards Grafana
│   ├── kafka-overview.json         # Vue d'ensemble
│   ├── kafka-topics.json          # Métriques par topic
│   └── kafka-cluster.json         # Métriques cluster
│
└── docs/                          # Documentation
    ├── README.md                  # Documentation complète
    ├── QUICKSTART.md             # Guide démarrage rapide
    ├── PROMETHEUS_QUERIES.md     # Requêtes Prometheus
    └── SUMMARY.md                # Ce fichier
```

## 🔑 Changements Clés vs Configuration Initiale

### ❌ AVANT (Incorrect)
```yaml
services:
  kafka-1:
    environment:
      KAFKA_JMX_PORT: 9100
      # ❌ Pas de KAFKA_OPTS
    depends_on:
      - jmx-exporter  # ❌ Container séparé

  jmx-exporter:  # ❌ Container JMX Exporter externe
    image: sscaling/jmx-prometheus-exporter
```

### ✅ APRÈS (Correct)
```yaml
services:
  kafka-1:
    environment:
      KAFKA_JMX_PORT: 9100
      # ✅ JMX Exporter intégré via Java Agent
      KAFKA_OPTS: '-javaagent:/usr/share/jmx-exporter/jmx_prometheus_javaagent.jar=8080:/usr/share/jmx-exporter/kafka-broker.yml'
    ports:
      - "8080:8080"  # ✅ Port pour Prometheus
    volumes:
      - ./jmx-exporter:/usr/share/jmx-exporter  # ✅ Config montée

  # ❌ Plus de container jmx-exporter séparé
```

## 🎯 Flux des Métriques

```
1. Kafka JMX MBeans
   ↓
2. JMX Exporter (Java Agent dans Kafka)
   ↓ (convertit JMX → format Prometheus)
3. HTTP endpoint :8080/metrics
   ↓
4. Prometheus (scrape toutes les 15s)
   ↓ (stocke dans TSDB)
5. Grafana (requêtes PromQL)
   ↓
6. Dashboards visuels
```

## 📊 Métriques Collectées

### Broker Metrics
- Messages in/out per second
- Bytes in/out per second
- Under-replicated partitions
- Offline partitions
- Leader count
- Partition count

### Performance Metrics
- Request latency (P50, P95, P99)
- Request handler idle %
- Network processor idle %
- Log flush rate & latency

### Controller Metrics
- Active controller count
- Leader elections
- Unclean leader elections

### Replication Metrics
- ISR shrinks/expands
- Failed ISR updates

## 🚀 Démarrage Rapide

```bash
# 1. Installation
chmod +x setup.sh
./setup.sh

# 2. Démarrage
docker-compose up -d

# 3. Vérification
curl http://localhost:8080/metrics | head
```

## 🔗 URLs Importantes

| Service | URL | Credentials |
|---------|-----|-------------|
| Grafana | http://localhost:3000 | admin/admin |
| Prometheus | http://localhost:9090 | - |
| Kafka UI | http://localhost:8888 | - |
| JMX Exporter (K1) | http://localhost:8080/metrics | - |
| JMX Exporter (K2) | http://localhost:8081/metrics | - |
| JMX Exporter (K3) | http://localhost:8082/metrics | - |

## ✅ Checklist de Vérification

- [ ] JMX Exporter JAR téléchargé (`setup.sh`)
- [ ] Dashboards Grafana téléchargés (`setup.sh`)
- [ ] Services démarrés (`docker-compose ps`)
- [ ] Métriques disponibles (`curl localhost:8080/metrics`)
- [ ] Prometheus scrape les targets (`http://localhost:9090/targets`)
- [ ] Grafana datasource configurée
- [ ] Dashboards visibles dans Grafana

## 🧪 Test du Monitoring

```bash
# 1. Créer un topic
make test-topic

# 2. Générer de la charge
make load-test

# 3. Voir les métriques dans Grafana
# → Dashboards → Kafka Overview
```

## 📚 Documentation

- **README.md** - Documentation complète
- **QUICKSTART.md** - Guide de démarrage rapide
- **PROMETHEUS_QUERIES.md** - Exemples de requêtes
- **Makefile** - Commandes pratiques

## 🔧 Configuration Personnalisée

### Modifier les métriques collectées
Éditez `jmx-exporter/kafka-broker.yml`

### Modifier l'intervalle de scraping
Éditez `prometheus.yml` → `scrape_interval`

### Ajouter des dashboards
Placez les fichiers JSON dans `dashboards/`

## 🐛 Troubleshooting

### Métriques non visibles
```bash
# Vérifier JMX Exporter
curl http://localhost:8080/metrics

# Vérifier logs Kafka
docker-compose logs kafka-1 | grep -i jmx

# Vérifier targets Prometheus
curl http://localhost:9090/api/v1/targets
```

### Kafka ne démarre pas
```bash
# Vérifier que le JAR est présent
docker exec kafka-1 ls -la /usr/share/jmx-exporter/

# Vérifier les permissions
docker exec kafka-1 ls -la /usr/share/jmx-exporter/jmx_prometheus_javaagent.jar
```

## 🎓 Ressources

### Documentation Officielle
- [Confluent - Monitoring with JMX](https://docs.confluent.io/platform/current/kafka/monitoring.html)
- [JMX Monitoring Stacks (Confluent)](https://github.com/confluentinc/jmx-monitoring-stacks)
- [Prometheus JMX Exporter](https://github.com/prometheus/jmx_exporter)

### Articles de Blog
- [Monitor Kafka Clusters with Prometheus, Grafana, and Confluent](https://www.confluent.io/blog/monitor-kafka-clusters-with-prometheus-grafana-and-confluent/)

## 📝 Notes Importantes

1. **JMX Exporter DOIT être intégré** dans les conteneurs Kafka via `KAFKA_OPTS`
2. **Pas de container JMX Exporter séparé** nécessaire
3. Les métriques sont exposées sur des **ports HTTP** (8080-8082)
4. Prometheus **scrape directement** ces endpoints HTTP
5. Configuration testée avec **Confluent Platform 7.9.0**

## 🎉 Conclusion

Cette configuration suit les **best practices de Confluent** et permet un monitoring complet de votre cluster Kafka. Elle est prête pour le développement et peut être adaptée pour la production avec les ajustements de sécurité nécessaires.
