FROM gcc:latest AS builder

# Aggiungi pkg-config alle dipendenze
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libcmocka-dev \
    pkg-config

WORKDIR /usr/src/app
COPY . .

RUN make all

# STAGE 2: Esecuzione
FROM debian:bookworm-slim

# Installa solo la libreria a runtime (libpq)
RUN apt-get update && apt-get install -y libpq5 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
# Copiamo solo il file compilato dallo stage precedente
COPY --from=builder /usr/src/app/app.out .

# Comando di avvio
CMD ["./app.out"]