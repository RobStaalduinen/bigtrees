# Mirrors the production render environment so local output matches the box:
# Ubuntu amd64 (t3.small is x86_64), the same wkhtmltopdf build the
# wkhtmltopdf-binary gem selects there, and Archivo installed the same way.
#
# --platform is deliberate. On Apple Silicon this runs under emulation and is
# slower, but font metrics and pagination then match production exactly, which
# is the entire point of this image.
FROM --platform=linux/amd64 ubuntu:22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      fontconfig \
      libjpeg-turbo8 \
      libx11-6 \
      libxext6 \
      libxrender1 \
      xfonts-75dpi \
      xfonts-base \
      zlib1g \
  && rm -rf /var/lib/apt/lists/*

# Extracted from the installed gem by render.sh — same binary as production.
COPY wkhtmltopdf /usr/local/bin/wkhtmltopdf
RUN chmod +x /usr/local/bin/wkhtmltopdf

# Exactly the server-side font install.
COPY fonts/ /usr/local/share/fonts/archivo/
RUN chmod 644 /usr/local/share/fonts/archivo/*.ttf \
  && fc-cache -fv \
  && fc-list | grep -i archivo \
  && fc-match Archivo

WORKDIR /work
ENTRYPOINT ["wkhtmltopdf"]
