#!/bin/bash
# convert-cv.sh
# Converts cv-writer markdown output to DOCX using pandoc + dotx templates.
# Usage: ./convert-cv.sh <cv_md_path> <cl_md_path> <output_dir> <plugin_dir> <cv_template_path>
#
# <cv_template_path> (arg 5) is the CV .dotx reference template, resolved by the
# orchestrator from the career-data config (`cv_template`, R-38). The personal CV
# template lives in career-data (R-37), NOT in the plugin — so it must be passed
# in, never hardcoded. (R-42: arg 5 added; the old build hardcoded a literal
# `{{USER_DOTX_FILE}}.dotx` placeholder and a stale `application-files-export`
# footer path, which broke every export.)
set -euo pipefail

CV_MD="$1"
CL_MD="$2"
OUTPUT_DIR="$3"
PLUGIN_DIR="$4"
CV_TEMPLATE="${5:-}"

if [ -z "${CV_TEMPLATE}" ] || [ ! -f "${CV_TEMPLATE}" ]; then
  echo "ERROR: CV template not found at '${CV_TEMPLATE:-<empty>}'. Pass the resolved \$CV_TEMPLATE (career-data 'cv_template', R-38) as argument 5." >&2
  exit 1
fi

CV_DOCX="${OUTPUT_DIR}/$(basename "${CV_MD%.md}").docx"
CL_DOCX="${OUTPUT_DIR}/$(basename "${CL_MD%.md}").docx"

mkdir -p "${OUTPUT_DIR}"

# Append static Education and Languages sections before conversion
CV_WITH_FOOTER="/tmp/cv-with-footer-$(basename "${CV_MD}")"
{ cat "${CV_MD}"; echo; cat "${PLUGIN_DIR}/skills/career-engine-export/static-cv-footer.md"; } > "${CV_WITH_FOOTER}"

pandoc "${CV_WITH_FOOTER}" \
  --reference-doc="${CV_TEMPLATE}" \
  -o "${CV_DOCX}"

pandoc "${CL_MD}" \
  --reference-doc="${PLUGIN_DIR}/references/cover-letter-template.dotx" \
  -o "${CL_DOCX}"

ls -lh "${CV_DOCX}" "${CL_DOCX}"
echo "Conversion complete."
