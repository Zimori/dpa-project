# few notes for dev team (some will be included in the final README)

## Difference between MusicBrainz and ListenBrainz
- ListenBrainz dumps: Listening events (user, timestamp, track/artist MBID)
- MusicBrainz dumps: Artist, country, genre/tags, release dates, collaborations
Check structures:
https://listenbrainz.readthedocs.io/en/latest/users/json.html
https://musicbrainz.org/doc/MusicBrainz_Database/Schema

## About downloading data

listenbrainz-listens-dump-2706-20261008-000002-..> 08-Oct-2026 00:02    189M
listenbrainz-listens-dump-2706-20261008-000002-..> 08-Oct-2026 00:07      32
listenbrainz-listens-dump-2706-20261008-000002-..> 08-Oct-2026 00:07      64
listenbrainz-spark-dump-2706-20261008-000002-in..> 08-Oct-2026 00:07    201M
listenbrainz-spark-dump-2706-20261008-000002-in..> 08-Oct-2026 00:07      32
listenbrainz-spark-dump-2706-20261008-000002-in..> 08-Oct-2026 00:07      64


### What's the difference between "listens" and "spark" (189MB vs 201MB) archives?
"spark-dump" was specifically generated for Apache Spark cluster
Basically, records are partitioned in a way its loadable directly into a pyspark df.

### Why do we take specific dates datasets instead of a full export?
The full export dataset itself is 226GB itself... compressed. So unless you have a NASA pc, we will stick to incremental.
We take multiple incremental datasets (few days in a row), summed up they should reach a few GB.

### Why are there two folders for each day anyway? Which one to use? 
Inside the "incremental" dir, we notice there is two folders for each day 
(e.g: listenbrainz-dump-2707-20261008-000003-incremental and listenbrainz-dump-2706-20261008-000002-incremental).
Basically, one of them corresponds to the data dump we're looking for (containing 2 files of roughly 200MB) and the other one is an "empty" archive, a stub.

### Why are we using a LATEST variable instead of simply fetching MusicBrainz dump?
LATEST is a pointer that guarantees always finding an existing folder since MetaBrainz deletes and updates dump folders.
(to complete)

### What about the other files inside the data dump directory?
Don't bother with that, they are checksum files only used to verify donwloading was done without corruption.

