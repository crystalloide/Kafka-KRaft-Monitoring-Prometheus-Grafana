# 📊 Requêtes Prometheus Utiles pour Kafka

## 🎯 Métriques de Production

### Messages par seconde (par broker)
```promql
rate(kafka_server_brokertopicmetrics_messagesin_total[5m])
```

### Bytes entrants par seconde
```promql
rate(kafka_server_brokertopicmetrics_bytesinpersec_total[5m])
```

### Bytes sortants par seconde
```promql
rate(kafka_server_brokertopicmetrics_bytesoutpersec_total[5m])
```

### Throughput total du cluster (messages/s)
```promql
sum(rate(kafka_server_brokertopicmetrics_messagesin_total[5m]))
```

## ⚠️ Métriques d'Alertes

### Partitions sous-répliquées
```promql
kafka_server_replicamanager_underreplicatedpartitions > 0
```

### Partitions sous le Min ISR
```promql
kafka_server_replicamanager_underminisrpartitioncount > 0
```

### Partitions offline
```promql
kafka_controller_kafkacontroller_offlinepartitionscount > 0
```

### Controller actif (doit être 1)
```promql
kafka_controller_kafkacontroller_activecontrollercount
```

### ISR Shrinks (réductions ISR)
```promql
rate(kafka_server_replicamanager_isrshrinkspers_total[5m]) > 0
```

### Failed ISR Updates
```promql
rate(kafka_server_replicamanager_failedisrupdates_total[5m]) > 0
```

## 🔄 Métriques de Réplication

### ISR Expansions par seconde
```promql
rate(kafka_server_replicamanager_isrexpandspersec_total[5m])
```

### Leader Elections par seconde
```promql
rate(kafka_controller_controllerstats_leaderelectionrateandtimems_count[5m])
```

### Unclean Leader Elections (doit être 0)
```promql
kafka_controller_controllerstats_uncleanleaderelections_total
```

## 📈 Métriques de Performance

### Latence moyenne des requêtes (ms)
```promql
kafka_network_requestmetrics_totaltimems{quantile="0.5"}
```

### Latence 99e percentile des requêtes (ms)
```promql
kafka_network_requestmetrics_totaltimems{quantile="0.99"}
```

### Request Handler Idle %
```promql
kafka_server_kafkarequesthandlerpool_requesthandleravgidlepercent
```

### Utilisation CPU des Request Handlers
```promql
100 - (kafka_server_kafkarequesthandlerpool_requesthandleravgidlepercent * 100)
```

### Network Processor Idle %
```promql
kafka_network_processor_idlepercent
```

## 💾 Métriques de Stockage

### Log Flush Rate
```promql
rate(kafka_log_logflushstats_logflushrateandtimems_count[5m])
```

### Log Flush Latency (moyenne)
```promql
kafka_log_logflushstats_logflushrateandtimems{quantile="0.5"}
```

### Taille des logs par topic
```promql
kafka_log_log_size
```

## 🎛️ Métriques du Cluster

### Nombre de partitions par broker
```promql
kafka_server_replicamanager_partitioncount
```

### Nombre de leaders par broker
```promql
kafka_server_replicamanager_leadercount
```

### État du broker (3 = running)
```promql
kafka_server_kafkaserver_brokerstate
```

## 📊 Requêtes de Produce/Fetch

### Requêtes Produce par seconde
```promql
rate(kafka_network_requestmetrics_requestspersec{request="Produce"}[5m])
```

### Requêtes Fetch par seconde
```promql
rate(kafka_network_requestmetrics_requestspersec{request="Fetch"}[5m])
```

### Latence Produce (99e percentile)
```promql
kafka_network_requestmetrics_totaltimems{request="Produce",quantile="0.99"}
```

### Latence Fetch (99e percentile)
```promql
kafka_network_requestmetrics_totaltimems{request="Fetch",quantile="0.99"}
```

## 🎯 Top N Queries

### Top 3 des brokers par messages/s
```promql
topk(3, rate(kafka_server_brokertopicmetrics_messagesin_total[5m]))
```

### Top 3 des brokers par bytes entrants
```promql
topk(3, rate(kafka_server_brokertopicmetrics_bytesinpersec_total[5m]))
```

### Top 5 des topics par taille
```promql
topk(5, kafka_log_log_size)
```

## 🚨 Exemples d'Alertes

### Alerte: Partitions sous-répliquées
```promql
ALERT UnderReplicatedPartitions
IF kafka_server_replicamanager_underreplicatedpartitions > 0
FOR 5m
LABELS { severity = "warning" }
ANNOTATIONS {
  summary = "Kafka has under-replicated partitions",
  description = "Broker {{ $labels.instance }} has {{ $value }} under-replicated partitions"
}
```

### Alerte: Partitions offline
```promql
ALERT OfflinePartitions
IF kafka_controller_kafkacontroller_offlinepartitionscount > 0
FOR 1m
LABELS { severity = "critical" }
ANNOTATIONS {
  summary = "Kafka has offline partitions",
  description = "Cluster has {{ $value }} offline partitions"
}
```

### Alerte: Pas de controller actif
```promql
ALERT NoActiveController
IF kafka_controller_kafkacontroller_activecontrollercount < 1
FOR 1m
LABELS { severity = "critical" }
ANNOTATIONS {
  summary = "No active Kafka controller",
  description = "No active controller detected in the cluster"
}
```

### Alerte: Request Handler Overload
```promql
ALERT RequestHandlerOverload
IF (100 - (kafka_server_kafkarequesthandlerpool_requesthandleravgidlepercent * 100)) > 90
FOR 5m
LABELS { severity = "warning" }
ANNOTATIONS {
  summary = "Kafka request handlers are overloaded",
  description = "Request handlers on {{ $labels.instance }} are {{ $value }}% utilized"
}
```

### Alerte: Latence élevée
```promql
ALERT HighProduceLatency
IF kafka_network_requestmetrics_totaltimems{request="Produce",quantile="0.99"} > 500
FOR 5m
LABELS { severity = "warning" }
ANNOTATIONS {
  summary = "High Kafka produce latency",
  description = "99th percentile produce latency is {{ $value }}ms on {{ $labels.instance }}"
}
```

## 📝 Notes

- **[5m]** = fenêtre de 5 minutes pour le calcul du taux
- **rate()** = calcule le taux de changement par seconde
- **topk()** = retourne les N valeurs les plus élevées
- **sum()** = agrège les valeurs
- **quantile** = percentile (0.5 = médiane, 0.99 = 99e percentile)

## 🔗 Pour aller plus loin

Consultez la documentation Prometheus:
- [Querying basics](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Operators](https://prometheus.io/docs/prometheus/latest/querying/operators/)
- [Functions](https://prometheus.io/docs/prometheus/latest/querying/functions/)
