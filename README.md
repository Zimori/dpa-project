# Music Artist Bridge Detection

**Question:** Do certain music artists act as bridges that connect different countries or genres, and does that structural role show up in how people listen to them?

This repository contains our DISS-DPA project. Part 1 (Volume) uses Spark SQL on ListenBrainz listening data joined with MusicBrainz artist metadata.

## Data

Both datasets come from the MetaBrainz Foundation and are released under CC0.

| Dataset | Role in Pipeline | Source URL |
|---|---|---|
| **ListenBrainz** | Event logs (listens, timestamps, artist MBIDs) | https://data.metabrainz.org/pub/musicbrainz/listenbrainz/incremental/ |
| **MusicBrainz** | Entity metadata & relations (artists, areas, collaborations) | https://data.metabrainz.org/pub/musicbrainz/data/fullexport/ |

## Prerequisites

- System tools: `curl`, `tar`, `lbzip2`
- Docker and Docker Compose, installed and running
- At least 15-20 GB of free disk space (compressed dumps and extracted tables)

## How to reproduce

1. **Clone the repository and install the tools** (Ubuntu/Debian):

```bash
git clone https://github.com/Zimori/dpa-project.git
cd dpa-project

sudo apt update && sudo apt install -y curl lbzip2 tar
```

2. **Download the data.** From the root of the repository, run:

```bash
   chmod +x get_data.sh
   ./get_data.sh
```

This downloads the MusicBrainz full export and the ListenBrainz dumps, and keeps only the tables we need. The MusicBrainz export is about 7.2 GB and can take over an hour.

3. **Start the environment:**

```bash
   docker compose up
```

The Jupyter web interface is then available at http://localhost:8889.

4. **Run the pipeline.** In Jupyter, open `src/part1.ipynb` and run all cells in order. The notebook does the ingestion, the data cleaning and the Spark SQL analysis. Parquet tables are in `work/data/processed/`.
