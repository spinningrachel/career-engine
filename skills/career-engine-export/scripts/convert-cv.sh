#!/bin/bash
# convert-cv.sh
# Converts cv-writer markdown output to DOCX using pandoc + dotx templates.
# Usage: ./convert-cv.sh <cv_md_path> <cl_md_path> <output_dir> <plugin_dir> <cv_template_path> <cl_template_path>
#
# <cv_template_path> (arg 5) and <cl_template_path> (arg 6) are the .dotx reference
# templates, resolved by the orchestrator from the fixed career-data path
# ${CAREER_DATA}/references/templates/{cv.dotx,cover-letter-template.dotx} — no
# config key, no plugin-side fallback. The personal templates live in career-data
# (R-37), NOT in the plugin — so both must be passed in, never hardcoded.
# (R-42: arg 5 added; the old build hardcoded a literal `{{USER_DOTX_FILE}}.dotx`
# placeholder and a stale `application-files-export` footer path, which broke every
# export. 2026-07-04: arg 6 added — the script previously hardcoded the plugin's
# own default `references/cover-letter-template.dotx` for every cover letter
# export, silently ignoring the user's actual personalized template every run.)
set -euo pipefail

CV_MD="$1"
CL_MD="$2"
OUTPUT_DIR="$3"
PLUGIN_DIR="$4"
CV_TEMPLATE="${5:-}"
CL_TEMPLATE="${6:-}"

if [ -z "${CV_TEMPLATE}" ] || [ ! -f "${CV_TEMPLATE}" ]; then
  echo "ERROR: CV template not found at '${CV_TEMPLATE:-<empty>}'. Pass the resolved \$CV_TEMPLATE (career-data references/templates/cv.dotx) as argument 5." >&2
  exit 1
fi

if [ -z "${CL_TEMPLATE}" ] || [ ! -f "${CL_TEMPLATE}" ]; then
  echo "ERROR: Cover letter template not found at '${CL_TEMPLATE:-<empty>}'. Pass the resolved \$CL_TEMPLATE (career-data references/templates/cover-letter-template.dotx) as argument 6." >&2
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
  --reference-doc="${CL_TEMPLATE}" \
  -o "${CL_DOCX}"

ls -lh "${CV_DOCX}" "${CL_DOCX}"
echo "Conversion complete."
