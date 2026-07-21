FULL-RESOLUTION ARCHIVE — local only.

Put the original, untouched photo files here (as downloaded from WordPress or
straight off a scanner — do NOT re-encode or resize them). This folder is
GIT-IGNORED (see .gitignore); only this README is tracked. The rest lives on
your machine and needs a backup outside git.

Why not in git:
- Nothing on the served website reads these files — the site only serves the
  smaller derivatives in assets/img/photos/{full,thumbs}/.
- Git handles hundreds of MB of binary blobs badly (no meaningful diffs, slow
  clones, bloated history).

Where to back this folder up:
- An external drive or NAS
- Cloud storage (iCloud / Google Drive / Dropbox / Backblaze)
- Object storage (AWS S3 / Cloudflare R2) — see README.md's "Object storage
  (future)" section if you ever want to serve high-res downloads from the site

The website serves smaller derivative copies generated from these:
  assets/img/photos/full/    display copies for the lightbox (~2560px)
  assets/img/photos/thumbs/  grid thumbnails (~600px square)

Regenerate the derivatives after adding/removing files here:
  ./scripts/rebuild-photos.sh
