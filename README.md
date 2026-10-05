# DPA PROJECT (question goes there)

Steps in order to reproduce the project
## 1. Download data
```bash
./get_data.sh
```
in the root directory.
## 2. Launch environment
```bash
docker compose up
```

Webinterface is available  at [http://localhost:8889](http://localhost:8889)

## 3. Run pipeline
```bash
src/part1.ipynb
```
Ingestion, Data Cleaning, Spark SQL analysis.
