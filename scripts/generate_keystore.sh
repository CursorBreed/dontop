#!/usr/bin/env bash
# =============================================================================
# generate_keystore.sh — Local keystore generation for Don't Tap Rogue Op
#
# PRIVACY NOTICE:
#   This script does NOT read, collect, or transmit any system information,
#   IP addresses, usernames, hostnames, MAC addresses, or location data.
#   Every value is typed manually by the operator.
# =============================================================================
set -euo pipefail

KEYSTORE_FILE="donttapop-release.jks"
VALIDITY_DAYS=10000

echo "============================================================"
echo "  Don't Tap Rogue Op — Keystore Generator"
echo "============================================================"
echo ""
echo "  This script will prompt you for company/org details only."
echo "  It does NOT auto-fill or read any system/user/IP/location data."
echo ""
echo "------------------------------------------------------------"

# ── Collect company details (minimum 5 fields) ─────────────────
read -rp "  Key alias (e.g. donttapop-release): " KEY_ALIAS
echo ""

read -rsp "  Key password (hidden): " KEY_PASSWORD
echo ""

read -rsp "  Keystore / store password (hidden): " STORE_PASSWORD
echo ""

read -rp "  Full name (first and last): " CN
echo ""

read -rp "  Organization / Company name: " ORG
echo ""

read -rp "  Organizational unit / Team name: " OU
echo ""

read -rp "  City / Locality: " CITY
echo ""

read -rp "  State / Province: " STATE
echo ""

read -rp "  Two-letter country code (e.g. US, NG, GB): " COUNTRY
echo ""

# ── Validate required fields ───────────────────────────────────
if [[ -z "$KEY_ALIAS" || -z "$KEY_PASSWORD" || -z "$STORE_PASSWORD" || \
      -z "$CN" || -z "$ORG" || -z "$OU" || -z "$CITY" || -z "$STATE" || \
      -z "$COUNTRY" ]]; then
  echo "ERROR: All fields are required. Aborting."
  exit 1
fi

DNAME="CN=${CN}, OU=${OU}, O=${ORG}, L=${CITY}, ST=${STATE}, C=${COUNTRY}"

echo ""
echo "------------------------------------------------------------"
echo "  Generating keystore: ${KEYSTORE_FILE}"
echo "  Distinguished name:  ${DNAME}"
echo "------------------------------------------------------------"
echo ""

# ── Generate the JKS keystore ──────────────────────────────────
keytool -genkeypair \
  -v \
  -keystore "${KEYSTORE_FILE}" \
  -alias "${KEY_ALIAS}" \
  -keyalg RSA \
  -keysize 2048 \
  -validity ${VALIDITY_DAYS} \
  -storepass "${STORE_PASSWORD}" \
  -keypass "${KEY_PASSWORD}" \
  -dname "${DNAME}"

echo ""
echo "============================================================"
echo "  Keystore generated: ${KEYSTORE_FILE}"
echo "============================================================"
echo ""

# ── Encode to base64 ───────────────────────────────────────────
KEYSTORE_BASE64=$(base64 -w 0 "${KEYSTORE_FILE}" 2>/dev/null || base64 -i "${KEYSTORE_FILE}" 2>/dev/null)

echo "============================================================"
echo "  GITHUB SECRETS — Add these in your repository settings:"
echo "  Settings > Secrets and variables > Actions > New repository secret"
echo "============================================================"
echo ""
echo "  Secret Name:  DontTapOpBase64"
echo "  Secret Value:  (the base64 string printed below)"
echo ""
echo "--- BEGIN BASE64 KEYSTORE ---"
echo "${KEYSTORE_BASE64}"
echo "--- END BASE64 KEYSTORE ---"
echo ""
echo "  Secret Name:  DontTapOpStorePassword"
echo "  Secret Value:  <the store password you entered>"
echo ""
echo "  Secret Name:  DontTapOpKeyPassword"
echo "  Secret Value:  <the key password you entered>"
echo ""
echo "  Secret Name:  DontTapOpKeyAlias"
echo "  Secret Value:  ${KEY_ALIAS}"
echo ""
echo "============================================================"
echo "  IMPORTANT: Delete the .jks file after copying the base64!"
echo "  Do NOT commit the keystore to version control."
echo "============================================================"
echo ""
echo "  To delete:  rm ${KEYSTORE_FILE}"
echo ""
