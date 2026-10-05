# choose a base image
# see https://quay.io/organization/jupyter for some options
FROM jupyter/pyspark-notebook

# remove pre-existing work directory
RUN rmdir /home/jovyan/work

# copies the project folder with the correct permissions to the working
# directory of the container/notebook
COPY --chown=1000:100 project /home/jovyan
