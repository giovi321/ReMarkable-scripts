# The three scripts in one image, plus extract.py, which mail.sh calls. Python comes
# with offlineimap, so it needs no package of its own.
#
# The scripts run as three containers by a compose file (see the README). rmapi is not included: mount your existing, already-paired binary
# and its configuration instead, so the device token carries over.
#
# No unoconv either. LibreOffice would multiply the image size, so convert.sh in
# this image expects STIRLING_URL to point at a Stirling-PDF server.
FROM debian:trixie-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash ca-certificates curl inotify-tools offlineimap \
    && rm -rf /var/lib/apt/lists/*

COPY mail.sh convert.sh upload.sh extract.py /app/
RUN chmod 755 /app/*.sh /app/extract.py

WORKDIR /root
