"""Starts (and stops) a Spark session once so that the Kafka connector jars
are downloaded into the image's Ivy cache at build time."""
from pyspark.sql import SparkSession

KAFKA_PKG = "org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.3"

spark = (SparkSession.builder
         .master("local[1]")
         .config("spark.jars.packages", KAFKA_PKG)
         .getOrCreate())
print("Spark", spark.version, "ready with", KAFKA_PKG)
spark.stop()
