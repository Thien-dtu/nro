# NRO Offline Server - Dockerfile
# Base image: Python 3.11 on Debian
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    bash \
    wget \
    unzip \
    procps \
    net-tools \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir \
    requests \
    tqdm \
    pymysql \
    colorama

# Copy application files
COPY nro_deobfuscated.py /app/
COPY docker-entrypoint.sh /app/

# Make entrypoint executable
RUN chmod +x /app/docker-entrypoint.sh

# Set Java environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Expose game server ports
EXPOSE 14445 14444

# Set entrypoint
ENTRYPOINT ["/app/docker-entrypoint.sh"]

# Default command (interactive shell)
CMD ["/bin/bash"]
