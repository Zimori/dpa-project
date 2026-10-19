# Do certain music artists act as bridges that connect different countries or genres, and does that connect different countries or genres, and does that structural role show up in how people listen to them?

## Prerequisites

- **System tools**: `curl`, `tar`, `lbzip2`
- **Docker & Docker Compose** installed and running.
- **Disk Space**: At least 15–20 GB of free disk space (to store both compressed dumps and extracted tables).

## Steps in order to reproduce the project

### 1. Check installation of necessary tools

```bash
sudo apt update && sudo apt install -y curl lbzip2 tar
```

### 2. Download data

```bash
chmod +x get_data.sh
./get_data.sh
```

in the root directory.

### 3. Launch environment

```bash
docker compose up
```

Webinterface is available  at [http://localhost:8889](http://localhost:8889)

### 4. Run pipeline

```bash
src/part1.ipynb
```

Ingestion, Data Cleaning, Spark SQL analysis.
