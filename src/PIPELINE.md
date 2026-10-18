# Part 1 Pipeline

## What We Are Trying to Answer

Do certain music artists act as bridges that connect different countries or genres, and does that structural role show up in how people listen to them?

This first part focuses on getting the data in shape and running initial analyses to understand what we are working with before tackling the bridge question directly in Part 3.

---

## Step 1: Get the Raw Data In

We work with two data sources.

**ListenBrainz** gives us listening events: who listened to what and when. We downloaded 12 incremental daily dumps covering October 6 to 18, 2026. Instead of hardcoding each folder path, we use a glob pattern to auto-detect all dump folders so adding more data in the future requires no code changes. After loading with an explicit schema, we have **39,431,528 raw listen events**.

**MusicBrainz** gives us the artist and geographic metadata. We extract two tables from the full dump:
- `artist`: 3,015,712 artists with their name, type, and the area they are from
- `area`: 120,108 geographic entries covering countries, cities, regions, and subdivisions

Both sources are read with explicit schemas to avoid type inference errors on large files.

---

## Step 2: Clean What We Have

Before doing any analysis we clean each table.

For **listens**, we drop any row where `artist_credit_id` is null since we cannot link that listen to an artist. We also drop columns we will never use, keeping only `listened_at`, `user_id`, `artist_credit_id`, `artist_name`, and `recording_mbid`. This brings us from 39M down to **31,690,487 rows**, about 80% retention.

For **artist**, we drop rows where `area` is null. An artist with no area cannot be linked to a country, which makes them useless for our geographic analysis. We keep `id`, `name`, and `area`. Result: **1,497,472 artists**.

For **area**, we keep all rows but we make sure to keep the `type` column alongside `id` and `name`. This column is critical in the next step.

All three cleaned tables are written to parquet under `data/processed/` so we do not have to redo this work every time we restart the notebook.

---

## Step 3: Build the Main Join

This is the core of Part 1. We join listens to artist to area to get a table that tells us: for each listen event, which country is that artist from?

The key filter here is `WHERE area.type = 1`. The area table contains not just countries but also cities, regions, and subdivisions. Without this filter, almost every artist maps to a city or region and the country counts become meaningless. Type 1 means country only.

After the join we have **17,271,689 rows** with four columns: `user_id`, `artist_credit_id`, `artist_name`, and `country`.

We immediately write this joined table to parquet and reload it as a cached view. This is important because every downstream query builds on this join, and without caching, Spark would recompute the full three-table join from scratch each time, which causes timeouts.

---

## Step 4: Analyse the Data

With the joined table ready, we run a series of analyses.

**Top artists by listen count** shows which artists dominate the dataset. Radiohead (UK) leads with 116K listens, followed by Die drei ??? (Germany, 115K), Linkin Park (US, 106K), and The Beatles (UK, 103K). The US and UK dominate but Germany, Japan, and Australia also appear in the top 20.

**Top countries by listen volume** groups by country and counts total listens and unique users. The United States leads with 2.1M listens across 23K users, followed by the United Kingdom (769K), Germany (307K), Japan (240K), and Canada (208K). Visualized as a bar chart.

**Listens per day** filters to October 2026 and groups by date. Full days average around 1 million listens. Three days stand out as partial: Oct 8 (48K), Oct 11 (43K), and Oct 18 (4 listens). These are due to incomplete dumps and should be excluded from any time-based analysis.

**User activity distribution** looks at how many listens each user has. There are 37,988 users in total. The average is 834 listens but the median is only 122, which tells us the distribution is heavily skewed. A small number of very active users pull the average up. The top user has 428,100 listens.

**User listening diversity** asks: how many different countries do the artists a user listens to come from? We compute this per user and find the top user listens to artists from 132 different countries. The average across all users is 9.72 countries.

**Correlation** between the number of distinct artists a user listens to and the number of distinct countries those artists come from gives us **0.696**. This is a moderately strong positive relationship. Users who listen to more artists do tend to discover artists from more countries, but the two are not the same thing. Geographic diversity exists independently of listening volume.

**Bridge artist analysis** tries to find artists whose `artist_credit_id` maps to more than one origin country. The result is empty. In MusicBrainz, every artist has exactly one registered area. This means we cannot detect bridge behavior through origin country alone. This is a known limitation and will be addressed in Part 3 using the artist-to-artist collaboration graph.

---

## Step 5: Load Collaboration Graph Data

At the end of Part 1 we load `l_artist_artist`, the table that records relationships between artists such as collaborations, band memberships, and tributes. This gives us **865,360 relations**. We do not use this in Part 1 but it is registered as a SQL view and ready for Part 3 where we will build the actual bridge analysis on top of it.

---

## What We Learned in Part 1

The data is in good shape. We have a clean joined table of 17M listen events linked to artist origin countries. The correlation of 0.696 suggests that listening breadth and geographic diversity are related but not identical, which is an interesting starting point. The bridge query being empty is not a failure but a finding: the bridge question cannot be answered with static origin country data alone. It requires the collaboration graph, which is what Part 3 is for.

---

## Known Limitations

The listens table has no user location column so we cannot measure where listeners are from, only where artists are from. Genre data is not available in the tables we extracted and would require loading additional MusicBrainz tables. The incremental dumps also contain historical listens submitted during the download window, not just activity from October 2026.

---

## Data Sizes

| Table | Rows | Size |
|---|---|---|
| listens raw | 39,431,528 | ~1.28 GB |
| listens_clean | 31,690,487 | ~347 MB |
| artist_clean | 1,497,472 | ~29 MB |
| area_clean | 120,108 | ~1.8 MB |
| joined | 17,271,689 | ~6 MB |
