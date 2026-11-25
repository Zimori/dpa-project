# JupyterLab + PySpark (local mode) + Kafka connector, nothing else.
FROM python:3.11-slim-bookworm

RUN apt-get update \
 && apt-get install -y --no-install-recommends openjdk-17-jre-headless procps \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Download the Spark-Kafka connector at build time, so the notebooks
# work even without internet access during the lab.
COPY warmup.py /tmp/warmup.py
RUN python /tmp/warmup.py

WORKDIR /workspace
EXPOSE 8888 4040
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", \
     "--IdentityProvider.token=", "--ServerApp.root_dir=/workspace"]
