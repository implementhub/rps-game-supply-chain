# Build-Context ist "src/" (siehe Taskfile: build-image / build-image-with-attestation
# rufen "docker buildx build ... -f src/docker/Dockerfile src" auf).
# Daher relative Pfade hier ab src/, z.B. "app/main.py".

FROM python:3.12-slim

# main.py nutzt nur die Python-Standardbibliothek. openssl wird zusätzlich
# benötigt, da get_own_spiffe_id() per subprocess "openssl x509 ..." aufruft.
RUN apt-get update \
    && apt-get install -y --no-install-recommends openssl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY app/main.py .

# Non-root User, um typische Trivy-Dockerfile-Misconfig-Findings
# (z.B. AVD-DS-0002 "Last USER should not be root") zu vermeiden.
RUN useradd --no-create-home --shell /usr/sbin/nologin appuser \
    && chown -R appuser:appuser /app
USER appuser

# Die SPIFFE-SVIDs (certs/svid.pem, svid_key.pem, svid_bundle.pem) und das
# Let's-Encrypt-Zertifikat werden NICHT ins Image gebacken (kurzlebige
# Secrets) – sie werden zur Laufzeit per Volume gemountet, z.B.:
#   docker run -v /pfad/zu/certs:/app/certs -v /pfad/zu/le:/app/le-cert:ro ...

EXPOSE 8001 8443

ENTRYPOINT ["python3", "main.py"]
