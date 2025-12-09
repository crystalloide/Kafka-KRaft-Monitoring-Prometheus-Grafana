# 🚀 Guide de démarrage rapide :

```bash
sudo rm -Rf Kafka-KRaft-Monitoring-Prometheus-Grafana
git clone https://github.com/crystalloide/Kafka-KRaft-Monitoring-Prometheus-Grafana
cd Kafka-KRaft-Monitoring-Prometheus-Grafana
sudo chmod 777 -Rf *
```

## Installation :

### 1️⃣ Démarrage (3 minutes ou plutôt 15 minutes si les images dockers ne sont pas présentes en local ...)

```bash
# Démarrer l'environnement
docker compose up -d

# Attendre que tout soit prêt (environ 30 secondes)
watch docker compose ps
```

### 2️⃣ Vérification (2 minutes)

```bash
# Vérifier que tout fonctionne
curl http://localhost:8080/metrics | head -20
```

## 🎯 Accès (après ~5 minutes le temps du lancement complet)

| Service | URL |
|---------|-----|
| 📊 **Grafana** | http://localhost:3000 |
| 📈 **Prometheus** | http://localhost:9090 |
| 📈 **Prometheus métriques** | http://localhost:8080/metrics |
| 🎛️ **Kafka UI** | http://localhost:8888 |

**Identifiants Grafana:** `admin` / `admin`

## 🧪 Test rapide

```bash
docker exec kafka-1 kafka-topics --bootstrap-server kafka-1:29091 --create --topic test --partitions 3 --replication-factor 3
```

## 📊 Visualiser les métriques dans Grafana

1. Aller sur http://localhost:3000
2. Se connecter avec `admin` / `admin`
3. Aller dans **Dashboards** 
4. Sélectionner **Kafka KRaft Cluster - Monitoring**

## 🔥 Générer de la charge pour voir les métriques

```bash
# Générer 1000 messages
for i in {1..1000}; do 
  echo "Test message $i" | docker exec -i kafka-1 \
    kafka-console-producer \
    --bootstrap-server kafka-1:29091 \
    --topic test
done
```

## ❓ Commandes utiles

```bash
# Voir les logs
docker-compose logs -f kafka-1

# Redémarrer un service
docker compose restart kafka-1

# Arrêter tout
docker compose stop 

# Arrêt et nettoyage complet
docker compose down -v
```

## 🐛 Problèmes fréquents

### Les métriques n'apparaissent pas

```bash
# Vérifier que JMX Exporter fonctionne
curl http://localhost:8080/metrics

# Vérifier Prometheus
curl http://localhost:9090/api/v1/targets
```

### Kafka ne démarre pas

```bash
# Vérifier les logs
docker compose logs kafka-1

# Vérifier la RAM disponible (minimum 8GB recommandé)
docker stats
```

### Port déjà utilisé

Modifier les ports dans `docker-compose.yml` si nécessaire.

## 📚 Pour aller plus loin

- Voir le **README.md** complet pour la documentation détaillée
- Utiliser le **Makefile** pour des commandes pratiques
- Consulter les dashboards Confluent dans `dashboards/`

## 🎉 C'est tout !

Votre cluster Kafka avec monitoring est opérationnel !

**Prochaines étapes suggérées:**
1. Explorer les dashboards Grafana
2. Créer vos propres topics
3. Configurer des alertes dans Prometheus
4. Personnaliser les dashboards Grafana
