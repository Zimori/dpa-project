# Part 1 Pipeline and Workflow

## 1. Ingestion

**ListenBrainz**
Read 3 days of incremental parquet dumps (Oct 6, 7, 8) with explicit schema. Key columns: listened_at, user_id, artist_credit_id, artist_name, recording_mbid. Total: 11,459,693 listens.

**MusicBrainz artist**
Read raw TSV file with explicit schema using tab separator and null value as \N. Key columns: id, gid, name, area, type. Total: 3,015,712 artists.

**MusicBrainz area**
Read raw TSV file with explicit schema. Key columns: id, name, type. Total: 120,108 areas.

All three tables written to parquet under `data/processed/`.

## 2. Cleaning

**listens**
Drop rows where artist_credit_id is null (needed for the join). Drop unused columns, keep: listened_at, user_id, artist_credit_id, artist_name, recording_mbid. Result: 9,312,832 rows.

**artist**
Drop rows where area is null (no country = useless for analysis). Keep: id, name, area. Result: 1,497,472 rows.

**area**
No rows dropped. Keep: id, name. Result: 120,108 rows.

Cleaned tables written to `data/processed/listens_clean`, `artist_clean`, `area_clean`.

## 3. Spark SQL Analysis

Load cleaned parquet tables and register as SQL views: listens, artist, area.

**Main join**
Reload area with the type column included. Register as SQL view. Join listens, artist, area with WHERE area.type = 1 to keep countries only (excludes cities, regions, subdivisions). Result: 5,080,347 rows with columns user_id, artist_credit_id, artist_name, country. Written to `data/processed/joined` and reloaded as cached view for performance.

**User country diversity**
Per user: count distinct origin countries of artists listened to, count distinct artists listened to. Ordered by distinct countries descending. Top user listens to artists from 126 different countries.

**Summary statistics**
Aggregate over all users: 28,430 total users, average 6.01 distinct countries per user, max 126, min 1.

**Top countries by listen volume**
Group joined by country, count total listens and unique users. Top 15 countries. United States leads with 2.1M listens, followed by United Kingdom (769K), Germany (307K), Japan (240K), Canada (208K).

**Bridge artist exploration**
Group joined by artist_name and artist_credit_id, count distinct countries and total listens. Filter HAVING country_reach > 1. Result is empty: every artist_credit_id maps to exactly one origin country. Bridge analysis via listener location is not possible in Part 1 since listens has no user country column.

**Correlation analysis**
Pearson correlation between distinct_artists_listened and distinct_countries_listened per user. Result: 0.696. Moderately strong positive correlation meaning users who listen to more artists tend to discover artists from more countries, but the relationship is not 1-to-1. Geographic diversity exists independently of listening volume.

## Key Decisions Made

- area.type = 1 is required to filter countries only, without it all per-artist country counts equal 1
- joined must be written to parquet before downstream queries, otherwise every query recomputes the full join from scratch causing timeouts
- Bridge query groups by artist_credit_id not artist_name to avoid name ambiguity (multiple artists sharing the same name like "Utopia" or "Karma")
- l_artist_artist (865,360 collaboration relations) is loaded but not used in Part 1, reserved for Part 3
