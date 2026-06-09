#!/bin/bash
# convert-cv.sh
# Converts cv-writer markdown output to DOCX using pandoc + dotx templates.
# Usage: ./convert-cv.sh <cv_md_path> <cl_md_path> <output_dir> <plugin_dir>
set -euo pipefail

CV_MD="$1"
CL_MD="$2"
OUTPUT_DIR="$3"
PLUGIN_DIR="$4"

CV_DOCX="${OUTPUT_DIR}/$(basename "${CV_MD%.md}").docx"
CL_DOCX="${OUTPUT_DIR}/$(basename "${CL_MD%.md}").docx"

mkdir -p "${OUTPUT_DIR}"

# Append static Education and Languages sections before conversion
CV_WITH_FOOTER="/tmp/cv-with-footer-$(basename "${CV_MD}")"
{ cat "${CV_MD}"; echo; cat "${PLUGIN_DIR}/skills/application-files-export/static-cv-footer.md"; } > "${CV_WITH_FOOTER}"

pandoc "${CV_WITH_FOOTER}" \
  --reference-doc="${PLUGIN_DIR}/references/{{USER_DOTX_FILE}}.dotx" \
  -o "${CV_DOCX}"

pandoc "${CL_MD}" \
  --reference-doc="${PLUGIN_DIR}/references/cover-letter-template.dotx" \
  -o "${CL_DOCX}"

ls -lh "${CV_DOCX}" "${CL_DOCX}"
echo "Conversion complete."
