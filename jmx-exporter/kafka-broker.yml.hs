# Configuration JMX Exporter pour Kafka Broker
# Basée sur https://github.com/confluentinc/jmx-monitoring-stacks

lowercaseOutputName: true
lowercaseOutputLabelNames: true

rules:
  # Broker Metrics - Messages In Per Sec
  - pattern: kafka.server<type=BrokerTopicMetrics, name=MessagesInPerSec><>Count
    name: kafka_server_brokertopicmetrics_messagesin_total
    type: COUNTER

  - pattern: kafka.server<type=BrokerTopicMetrics, name=MessagesInPerSec><>(OneMinuteRate|FiveMinuteRate|FifteenMinuteRate|MeanRate)
    name: kafka_server_brokertopicmetrics_messagesin
    type: GAUGE

  # Broker Metrics - Bytes In/Out Per Sec
  - pattern: kafka.server<type=BrokerTopicMetrics, name=(BytesInPerSec|BytesOutPerSec)><>Count
    name: kafka_server_brokertopicmetrics_$1_total
    type: COUNTER

  - pattern: kafka.server<type=BrokerTopicMetrics, name=(BytesInPerSec|BytesOutPerSec)><>(OneMinuteRate|FiveMinuteRate|FifteenMinuteRate|MeanRate)
    name: kafka_server_brokertopicmetrics_$1
    type: GAUGE

  # Request Metrics
  - pattern: kafka.network<type=RequestMetrics, name=RequestsPerSec, request=(\w+)><>(Count|OneMinuteRate|FiveMinuteRate|FifteenMinuteRate|MeanRate)
    name: kafka_network_requestmetrics_requestspersec
    labels:
      request: "$1"

  # Request Latency
  - pattern: kafka.network<type=RequestMetrics, name=TotalTimeMs, request=(\w+)><>(Mean|Min|Max|StdDev|50thPercentile|75thPercentile|95thPercentile|98thPercentile|99thPercentile|999thPercentile)
    name: kafka_network_requestmetrics_totaltimems
    labels:
      request: "$1"

  # Under Replicated Partitions
  - pattern: kafka.server<type=ReplicaManager, name=UnderReplicatedPartitions><>Value
    name: kafka_server_replicamanager_underreplicatedpartitions
    type: GAUGE

  # Under Min ISR Partition Count
  - pattern: kafka.server<type=ReplicaManager, name=UnderMinIsrPartitionCount><>Value
    name: kafka_server_replicamanager_underminisrpartitioncount
    type: GAUGE

  # Offline Partitions Count
  - pattern: kafka.controller<type=KafkaController, name=OfflinePartitionsCount><>Value
    name: kafka_controller_kafkacontroller_offlinepartitionscount
    type: GAUGE

  # Active Controller Count
  - pattern: kafka.controller<type=KafkaController, name=ActiveControllerCount><>Value
    name: kafka_controller_kafkacontroller_activecontrollercount
    type: GAUGE

  # Leader Election Rate and Time
  - pattern: kafka.controller<type=ControllerStats, name=LeaderElectionRateAndTimeMs><>(Count|OneMinuteRate|Mean|75thPercentile|95thPercentile|99thPercentile)
    name: kafka_controller_controllerstats_leaderelectionrateandtimems

  # Unclean Leader Elections Per Sec
  - pattern: kafka.controller<type=ControllerStats, name=UncleanLeaderElectionsPerSec><>Count
    name: kafka_controller_controllerstats_uncleanleaderelections_total
    type: COUNTER

  # Partition Count
  - pattern: kafka.server<type=ReplicaManager, name=PartitionCount><>Value
    name: kafka_server_replicamanager_partitioncount
    type: GAUGE

  # Leader Count
  - pattern: kafka.server<type=ReplicaManager, name=LeaderCount><>Value
    name: kafka_server_replicamanager_leadercount
    type: GAUGE

  # ISR Shrinks/Expands Per Sec
  - pattern: kafka.server<type=ReplicaManager, name=(IsrShrinksPerSec|IsrExpandsPerSec)><>Count
    name: kafka_server_replicamanager_$1_total
    type: COUNTER

  - pattern: kafka.server<type=ReplicaManager, name=(IsrShrinksPerSec|IsrExpandsPerSec)><>(OneMinuteRate)
    name: kafka_server_replicamanager_$1

  # Failed ISR Updates Per Sec
  - pattern: kafka.server<type=ReplicaManager, name=FailedIsrUpdatesPerSec><>Count
    name: kafka_server_replicamanager_failedisrupdates_total
    type: COUNTER

  # Log Flush Rate and Time
  - pattern: kafka.log<type=LogFlushStats, name=LogFlushRateAndTimeMs><>(Count|OneMinuteRate|Mean|75thPercentile|95thPercentile|99thPercentile)
    name: kafka_log_logflushstats_logflushrateandtimems

  # Request Handler Avg Idle Percent
  - pattern: kafka.server<type=KafkaRequestHandlerPool, name=RequestHandlerAvgIdlePercent><>(OneMinuteRate|Mean)
    name: kafka_server_kafkarequesthandlerpool_requesthandleravgidlepercent

  # Network Processor Avg Idle Percent
  - pattern: kafka.network<type=Processor, name=IdlePercent, networkProcessor=(\d+)><>(Value)
    name: kafka_network_processor_idlepercent
    labels:
      processor: "$1"

  # Broker State
  - pattern: kafka.server<type=KafkaServer, name=BrokerState><>Value
    name: kafka_server_kafkaserver_brokerstate
    type: GAUGE

  # ZooKeeper Client Metrics (si utilisé)
  - pattern: kafka.server<type=SessionExpireListener, name=(\w+)><>Count
    name: kafka_server_sessionexpirelistener_$1_total
    type: COUNTER

  # Quota Metrics
  - pattern: kafka.server<type=(Produce|Fetch|Request), user=(.+), client-id=(.+)><>(.+)
    name: kafka_server_quota_$1_$4
    labels:
      user: "$2"
      client: "$3"

  # Log Size
  - pattern: kafka.log<type=Log, name=Size, topic=(.+), partition=(.+)><>Value
    name: kafka_log_log_size
    labels:
      topic: "$1"
      partition: "$2"
    type: GAUGE

  # Règle générique pour capturer d'autres métriques importantes
  - pattern: kafka.(\w+)<type=(.+), name=(.+)><>(\w+)
    name: kafka_$1_$2_$3_$4
    type: GAUGE
