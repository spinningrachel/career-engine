#!/bin/bash
# convert-cv.sh
# Converts cv-writer markdown output to DOCX using pandoc + dotx templates.
# Usage: ./convert-cv.sh <cv_md_path> <cl_md_path> <output_dir> <cv_footer_path> <cv_template_path> <cl_template_path>
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
#
# <cv_footer_path> (arg 4, formerly the plugin dir) is the resolved career-data
# footer path $CV_FOOTER = ${CAREER_DATA}/references/static-cv-footer.md — no
# config key, no plugin-side fallback, same R-37 pattern as the two templates.
# (2026-07-09 fix: the script previously hardcoded the plugin's own
# skills/career-engine-export/static-cv-footer.md for every CV export — that
# plugin-shipped file had accumulated one real user's actual degree/university
# content, which meant every installation of this plugin was silently appending
# someone else's real Education/Languages section onto every user's exported CV.
# Confirmed live in the shipped repo, not theoretical. Same bug class as the two
# fixes above, just missed when they landed.)
#
# <cv_footer_path> is OPTIONAL (2026-07-12 fix): pass an empty string "" when
# pipeline-preferences.json's cv_footer.inject is false. The CV then converts
# with no appended footer content -- the user manages Education/Languages
# herself outside the pipeline (e.g. a personal Word macro applied after
# export), the same way this pipeline has always left the CV's optional
# ADDITIONAL section to the user's own post-export process. A non-empty path
# must still exist -- an empty string is the only way to skip the file.
set -euo pipefail

CV_MD="$1"
CL_MD="$2"
OUTPUT_DIR="$3"
CV_FOOTER="$4"
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

if [ -n "${CV_FOOTER}" ] && [ ! -f "${CV_FOOTER}" ]; then
  echo "ERROR: CV footer not found at '${CV_FOOTER}'. Pass the resolved \$CV_FOOTER (career-data references/static-cv-footer.md) as argument 4, or an empty string if cv_footer.inject is false in pipeline-preferences.json." >&2
  exit 1
fi

CV_DOCX="${OUTPUT_DIR}/$(basename "${CV_MD%.md}").docx"
CL_DOCX="${OUTPUT_DIR}/$(basename "${CL_MD%.md}").docx"

mkdir -p "${OUTPUT_DIR}"

# Append static Education and Languages sections before conversion, unless the user manages that content herself (empty CV_FOOTER)
CV_WITH_FOOTER="/tmp/cv-with-footer-$(basename "${CV_MD}")"
if [ -n "${CV_FOOTER}" ]; then
  { cat "${CV_MD}"; echo; cat "${CV_FOOTER}"; } > "${CV_WITH_FOOTER}"
else
  cp "${CV_MD}" "${CV_WITH_FOOTER}"
fi

pandoc "${CV_WITH_FOOTER}" \
  --reference-doc="${CV_TEMPLATE}" \
  -o "${CV_DOCX}"

pandoc "${CL_MD}" \
  --reference-doc="${CL_TEMPLATE}" \
  -o "${CL_DOCX}"

ls -lh "${CV_DOCX}" "${CL_DOCX}"
echo "Conversion complete."
