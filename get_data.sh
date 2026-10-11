set -e # stop if anything breaks
# build data folder
mkdir -p data/raw data/processed data/raw/mb

# there we gather data from web sources

# fetch the current live dump directory name ()
LATEST=$(curl -sL https://data.metabrainz.org/pub/musicbrainz/data/fullexport/LATEST)
echo "latest musicbrainz dump OK"
MBFOLDER="data/raw/mb"

curl -L "https://data.metabrainz.org/pub/musicbrainz/data/fullexport/${LATEST}/mbdump.tar.bz2" \
     -o "${MBFOLDER}/mbdump.tar.bz2"

echo "fetching October 6 dataset"
curl -L https://data.metabrainz.org/pub/musicbrainz/listenbrainz/incremental/listenbrainz-dump-2702-20261006-000002-incremental/listenbrainz-spark-dump-2702-20261006-000002-incremental.tar -o ${MBFOLDER}/0610dump.tar
echo "fetching October 7 dataset"
curl -L https://data.metabrainz.org/pub/musicbrainz/listenbrainz/incremental/listenbrainz-dump-2704-20261007-000002-incremental/listenbrainz-spark-dump-2704-20261007-000002-incremental.tar -o ${MBFOLDER}/0710dump.tar
echo "fetching October 8 dataset"
curl -L https://data.metabrainz.org/pub/musicbrainz/listenbrainz/incremental/listenbrainz-dump-2706-20261008-000002-incremental/listenbrainz-spark-dump-2706-20261008-000002-incremental.tar -o ${MBFOLDER}/0810dump.tar

echo "datasets fetched, now proceeding to the uncompression of these"
# small loop to extract every file
for archive in ${MBFOLDER}/*.tar; do
    tar -xvf "$archive" -C "${MBFOLDER}"
done

# we extract the only 5 tables we need (--occurence to stop reading when found and lbzip2 for multi-thread for decompression)
tar -I lbzip2 --occurrence -xvf "${MBFOLDER}/mbdump.tar.bz2" -C "${MBFOLDER}/" mbdump/artist mbdump/area mbdump/l_artist_artist mbdump/link mbdump/link_type

echo "removing archive files..."
rm -f "${MBFOLDER}/mbdump.tar.bz2" "${MBFOLDER}"/*.tar

echo "Data acquired succesfully."

