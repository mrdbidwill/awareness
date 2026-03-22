#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="${1:-unknown}"
HOSTNAME="$(hostname -f 2>/dev/null || hostname)"

EMAIL_TO="${EMAIL_TO:-}"
EMAIL_FROM="${EMAIL_FROM:-root@${HOSTNAME}}"

SUBJECT="Systemd failure: ${SERVICE_NAME} on ${HOSTNAME}"
BODY="$(systemctl status "${SERVICE_NAME}" --no-pager -n 50 2>&1)"

if [[ -z "${EMAIL_TO}" ]]; then
  logger -t systemd-notify "EMAIL_TO not set; ${SUBJECT}. ${BODY}"
  exit 0
fi

if command -v mail >/dev/null 2>&1; then
  printf "%s\n\n%s\n" "${SUBJECT}" "${BODY}" | mail -s "${SUBJECT}" -r "${EMAIL_FROM}" "${EMAIL_TO}"
  exit 0
fi

if command -v mailx >/dev/null 2>&1; then
  printf "%s\n\n%s\n" "${SUBJECT}" "${BODY}" | mailx -s "${SUBJECT}" -r "${EMAIL_FROM}" "${EMAIL_TO}"
  exit 0
fi

if command -v sendmail >/dev/null 2>&1; then
  {
    printf "From: %s\n" "${EMAIL_FROM}"
    printf "To: %s\n" "${EMAIL_TO}"
    printf "Subject: %s\n\n" "${SUBJECT}"
    printf "%s\n" "${BODY}"
  } | sendmail -t
  exit 0
fi

logger -t systemd-notify "mail/mailx/sendmail not found; ${SUBJECT}. ${BODY}"
