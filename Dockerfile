# --- Stage 1: Build (Menggunakan image builder resmi Golang) ---
# Menggunakan Debian sebagai basis image build
FROM golang:1.24-bullseye AS builder

# Atur direktori kerja di dalam container
WORKDIR /app

# Salin module dan file source code
COPY /src ./

# Kompilasi aplikasi.
# CGO_ENABLED=0 membuat binary statis, yang diperlukan saat menggunakan image base 'scratch' atau 'alpine' (walaupun kita menggunakan debian-slim di stage 2)
# -o app menentukan nama binary yang dihasilkan
RUN go mod download
RUN CGO_ENABLED=0 go build -o /app/app .

# --- Stage 2: Final (Menggunakan image yang jauh lebih kecil) ---
# Menggunakan debian slim (berbasis Debian, tetapi tanpa banyak paket) untuk image yang kecil dan aman.
FROM debian:bullseye-slim

# Ekspos port aplikasi
EXPOSE 8080

# Salin binary yang sudah dikompilasi dari stage 'builder'
COPY --from=builder /app/app /usr/local/bin/app

# Perintah default saat container dijalankan
CMD ["/usr/local/bin/app"]