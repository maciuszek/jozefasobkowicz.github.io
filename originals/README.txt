FULL-RESOLUTION ARCHIVE — quality at rest.

Put the original, untouched scans here (exactly as downloaded from WordPress or
your scanner — do NOT re-encode or resize them). This folder is committed to git
for backup/versioning but is EXCLUDED from the built website (see _config.yml),
so these large files never count toward the 1 GB served-site limit or get sent
to visitors.

The website serves smaller derivative copies generated from these:
  assets/img/photos/full/    display copies for the lightbox (~2560px)
  assets/img/photos/thumbs/  grid thumbnails (~600px square)

If this archive grows large, move it to object storage (S3 / Cloudflare R2)
and optionally drop it from the repo. See README.md.
