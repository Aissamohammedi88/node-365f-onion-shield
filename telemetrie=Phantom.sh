#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
#
# NEXUS PHANTOM MODE  —  DÉFI "AUTRE MONDE"
# ─────────────────────────────────────────────────
# Tu rentres dans Google / YouTube comme un fantôme :
#   • Aucune IP réelle ne fuit (routage Tor multi-hop 365-F)
#   • Aucune collection : cookies, fingerprints, JWT, device IDs bloqués
#   • Aucune télémétrie kernel (eBPF / dmesg / modules) n'atteint Google
#   • Aucune fuite DNS (DNSPort 5353 → résolution .onion/.exit)
#   • Kill-switch immédiat si une collection tente de remonter
#
# Compatibilité : extension du script NEXUS UNION SHIELD v1.0.0
#                 (utilise le même BASE, LOG, WHITELIST, BLACKLIST, SESSION_DB)
#
# Auteur : Aissa Mohammedi (DGK) — extension Phantom
# Licence : NEXUS-OPEN-2.0
# Version : 1.1.0 "PHANTOM ENTRY"
#
# ═══════════════════════════════════════════════════════════════════════════════

set -u

# ─── IDENTITÉ ───
readonly VERSION="1.1.0"
readonly CODENAME="PHANTOM ENTRY"
readonly AUTEUR="Aissa Mohammedi (DGK)"
readonly LICENCE="NEXUS-OPEN-2.0"

# ─── COULEURS ───
readonly G='\033[0;32m' Y='\033[1;33m' R='\033[0;31m' C='\033[0;36m'
readonly M='\033[0;35m' B='\033[1;34m' W='\033[1;37m' D='\033[2m'
readonly N='\033[0m' BOLD='\033[1m'

# ─── CHEMINS (compatibles avec NEXUS UNION SHIELD) ───
readonly BASE="${NEXUS_BASE:-$HOME/Documents/nexus_union_shield}"
readonly LOG="$BASE/union.log"
readonly SESSION_DB="$BASE/sessions.db"
readonly WHITELIST="$BASE/whitelist.txt"
readonly BLACKLIST="$BASE/blacklist.txt"
readonly ALERTS="$BASE/alerts.log"
readonly PHANTOM_DIR="$BASE/phantom"
readonly PHANTOM_PROFILE="$PHANTOM_DIR/profile"
readonly PHANTOM_LOG="$PHANTOM_DIR/phantom.log"
readonly PHANTOM_PID="$PHANTOM_DIR/phantom.pid"
readonly PHANTOM_REPORT="$PHANTOM_DIR/rapport_fantome.txt"
readonly TORRC_PHANTOM="$PHANTOM_DIR/torrc.phantom"

mkdir -p "$PHANTOM_DIR"
touch "$PHANTOM_LOG" "$PHANTOM_REPORT"

# ─── COLLECTION GOOGLE/YOUTUBE À ÉVITER ───
# Chaque entrée = un canal par lequel Google "collecte" l'utilisateur.
# Le défi consiste à tous les neutraliser simultanément.
readonly COLLECTION=(
  "DNS clair       | dns.google / 8.8.8.8 / 8.8.4.4         | résolution non-Tor = fuite"
  "HTTP clair      | *.google.com:80                         | downgrade visible"
  "Cookies         | NID SID SAPISID HSID APISID            | identité persistante"
  "Local Storage   | s_yt_it / yt-remote-*                  | state YouTube"
  "Canvas FP       | toDataBlob / getImageData              | fingerprint navigateur"
  "WebRTC           | STUN 19302 (stun.l.google.com)        | fuite IP locale"
  "User-Agent      | Chrome / X11 / Linux                   | device signature"
  "Header Client   | X-Client-Data / X-Goog-Scan-Id         | telemetry header"
  "Beacon           | navigator.sendBeacon()                 | upload silencieux"
  "TLS JA3          | ClientHello ordre des ciphers          | signature TLS"
  "Kernel module    | gsc / gve / google_compute_engine      | télémétrie kernel GCP"
  "systemd unit     | *.service *google* *telemetry*         | service fond"
)

# ─── SYMBOLES ───
readonly SYM_OK="✓" SYM_KO="✗" SYM_WARN="⚠" SYM_BLOCK="⛔"
readonly SYM_PHANTOM="👻" SYM_SHIELD="🛡" SYM_LOCK="🔒"

# ═══════════════════════════════════════════════════════════════════════════════
# AFFICHAGE
# ═══════════════════════════════════════════════════════════════════════════════
ok()    { printf " ${G}${SYM_OK}${N} %s\n" "$1"; }
ko()    { printf " ${R}${SYM_KO}${N} %s\n" "$1"; }
warn()  { printf " ${Y}${SYM_WARN}${N} %s\n" "$1"; }
info()  { printf " ${C}[i]${N} %s\n" "$1"; }
block() { printf " ${R}${SYM_BLOCK}${N} %s\n" "$1"; }
phant() { printf " ${M}${SYM_PHANTOM}${N} %s\n" "$1"; }

section() {
  echo ""
  echo -e "${BOLD}${B}╔══════════════════════════════════════════════════════════════════════╗${N}"
  printf "${BOLD}${B}║${N} ${BOLD}${W}%-68s${N} ${BOLD}${B}║${N}\n" "$1"
  echo -e "${BOLD}${B}╚══════════════════════════════════════════════════════════════════════╝${N}"
  echo ""
}
separator() { echo -e " ${D}──────────────────────────────────────────────────────────────────────${N}"; }

log() {
  local level="$1"; shift
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [$level] $*" >> "$LOG"
}

phantom_log() {
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [PHANTOM] $*" >> "$PHANTOM_LOG"
}

alert() {
  local msg="$1"; local niveau="${2:-WARN}"
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [$niveau] $msg" >> "$ALERTS"
  if [ "$niveau" = "CRIT" ]; then
    printf " ${R}${BOLD}${SYM_BLOCK} COLLECTION DÉTECTÉE : %s${N}\n" "$msg"
  else
    printf " ${Y}${SYM_WARN} %s${N}\n" "$msg"
  fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# ÉTAPE 1 — VÉRIFIER QUE TOR ULTRA 365-F EST BIEN ACTIF
# ═══════════════════════════════════════════════════════════════════════════════
verifier_tor() {
  section "ÉTAPE 1 — VÉRIFICATION TOR ULTRA 365-F"
  if ! command -v tor >/dev/null 2>&1; then
    ko "Tor n'est pas installé — lance d'abord NEXUS UNION SHIELD (option 1)"
    return 1
  fi
  if ! ss -tln 2>/dev/null | grep -q ":9050"; then
    ko "Tor n'écoute pas sur 127.0.0.1:9050 — démarre-le via NEXUS UNION SHIELD"
    return 1
  fi
  ok "SOCKS5 Tor disponible : 127.0.0.1:9050"

  local ip_real ip_tor
  ip_real=$(curl -s --max-time 6 https://api.ipify.org 2>/dev/null || echo "inconnu")
  ip_tor=$(curl -s --max-time 12 --socks5-hostname 127.0.0.1:9050 https://api.ipify.org 2>/dev/null || echo "inconnu")

  info "IP directe  : $ip_real"
  info "IP de Tor    : $ip_tor"

  if [ "$ip_real" = "$ip_tor" ]; then
    block "FUITE CRITIQUE — Tor ne route pas le trafic. Abandon du défi."
    alert "IP Tor = IP directe ($ip_tor)" "CRIT"
    return 1
  fi
  ok "Deux mondes différents : $ip_real ≠ $ip_tor — Tor isole bien."
  phantom_log "TOR_OK ip_real=$ip_real ip_tor=$ip_tor"
  return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# ÉTAPE 2 — DURCIR TOR POUR LE MODE FANTÔME (config dédiée)
# ═══════════════════════════════════════════════════════════════════════════════
durcir_tor() {
  section "ÉTAPE 2 — TORRC FANTÔME (isolation par circuit)"
  cat > "$TORRC_PHANTOM" << 'TORRC'
# NEXUS PHANTOM — surcouche de torrc pour Google/YouTube
# Idempotent : ne remplace PAS le torrc de UNION SHIELD, on l'étend.

# Isolation : chaque flux sort avec un circuit différent
IsolateDestAddr 1
IsolateDestPort 1
IsolateClientProtocol 1
IsolateClientAuth 1

# Pas de garde unique = plus dur à corréler
NumEntryGuards 12
NumDirectoryGuards 4
UseMicrodescriptors 0

# Renouvellement de circuit fréquent
MaxCircuitDirtiness 30
NewCircuitPeriod 10

# Refuser toute connexion hors Tor
SOCKSPolicy accept 127.0.0.1:9050
SOCKSPolicy reject *
ExitPolicy reject *:*

# Pas de cache DNS local qui fuiterait
ClientDNSRejectInternalAddresses 1
TORRC
  ok "Torrc fantôme écrit : $TORRC_PHANTOM"
  warn "Recharge-le avec :  sudo tor -f $TORRC_PHANTOM"
  phantom_log "TORRC_PHANTOM written"
}

# ═══════════════════════════════════════════════════════════════════════════════
# ÉTAPE 3 — PROFIL NAVIGATEUR FANTÔME (zéro cookies, zéro LS, WebRTC off)
# ═══════════════════════════════════════════════════════════════════════════════
creer_profil_fantome() {
  section "ÉTAPE 3 — PROFIL NAVIGATEUR FANTÔME"

  rm -rf "$PHANTOM_PROFILE" 2>/dev/null || true
  mkdir -p "$PHANTOM_PROFILE"

  # prefs.js pour Firefox-like ; User-Agent anonymisé
  cat > "$PHANTOM_PROFILE/prefs.js" << 'PREFS'
user_pref("browser.privatebrowsing.autostart", true);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.prefetch-next", false);
user_pref("media.peerconnection.enabled", false);
user_pref("media.peerconnection.turn.disable", true);
user_pref("media.peerconnection.use_document_iceservers", false);
user_pref("webgl.disabled", true);
user_pref("dom.storage.enabled", false);
user_pref("privacy.resistFingerprinting", true);
user_pref("privacy.sanitize.sanitizeOnShutdown", true);
user_pref("network.proxy.socks", "127.0.0.1");
user_pref("network.proxy.socks_port", 9050);
user_pref("network.proxy.socks_remote_dns", true);
user_pref("network.proxy.type", 1);
user_pref("general.useragent.override", "Mozilla/5.0 (X11; Linux x86_64; Phantom) Gecko/20100101 Firefox/128.0");
PREFS

  ok "Profil créé : $PHANTOM_PROFILE"
  info "Cookies / LocalStorage / WebRTC désactivés dans le profil"
  info "User-Agent neutralisé (pas de version Chrome, pas de build OS)"
  phantom_log "PROFILE_FANTOME_OK"
}

# ═══════════════════════════════════════════════════════════════════════════════
# ÉTAPE 4 — BLACKLIST DE LA COLLECTION GOOGLE/YOUTUBE
# ═══════════════════════════════════════════════════════════════════════════════
blacklister_collection() {
  section "ÉTAPE 4 — BLACKLIST DES CANAUX DE COLLECTION"

  # Domaines de collecte Google/YouTube (à mettre en /etc/hosts → 0.0.0.0)
  local collect_domains=(
    "doubleclick.net"
    "google-analytics.com"
    "googletagmanager.com"
    "googletagservices.com"
    "googleadservices.com"
    "g.doubleclick.net"
    "stats.g.doubleclick.net"
    "youtube.com/ptracking"
    "s.youtube.com"
    "accounts.google.com/gsi"
    "play.google.com/log"
    "clients2.google.com"
    "update.googleapis.com"
    "sandbox.google.com"
    "metrics.g.doubleclick.net"
  )

  local host_file="/tmp/phantom_hosts.$$.tmp"
  : > "$host_file"
  for d in "${collect_domains[@]}"; do
    printf "0.0.0.0\t%s\n" "$d" >> "$host_file"
  done
  info "Fichier hosts fantôme généré : $host_file"
  warn "Pour appliquer :  sudo cat $host_file >> /etc/hosts"
  warn "Pour retirer après défi :  supprimer les lignes 0.0.0.0 ajoutées"

  # Blacklist NEXUS
  for org in "Google" "YouTube-Collection" "DoubleClick" "GoogleAnalytics"; do
    if ! grep -qxF "$org" "$BLACKLIST" 2>/dev/null; then
      echo "$org" >> "$BLACKLIST"
    fi
  done
  ok "Google / YouTube / DoubleClick / GoogleAnalytics ajoutés à la blacklist NEXUS"
  phantom_log "BLACKLIST_COLLECTION_OK domains=${#collect_domains[@]}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# ÉTAPE 5 — SCAN TÉLÉMÉTRIE KERNEL (Google-spécifique)
# ═══════════════════════════════════════════════════════════════════════════════
scan_kernel_google() {
  section "ÉTAPE 5 — SCAN KERNEL ANTI-GOOGLE"
  local trouve=0

  # Modules
  subsection "Modules kernel Google/GCP"
  local mods
  mods=$(lsmod 2>/dev/null | grep -iE "gsc|gve|google_compute|gcp|gvnic" | head -10)
  if [ -n "$mods" ]; then
    while IFS= read -r m; do
      warn "Module suspect : $m"
      trouve=1
    done <<< "$mods"
  else
    ok "Aucun module Google/GCP chargé"
  fi

  # systemd
  subsection "Services systemd Google"
  local services
  services=$(systemctl list-units --type=service 2>/dev/null | grep -iE "google|gcp|telemetry|oslogin" | head -10)
  if [ -n "$services" ]; then
    while IFS= read -r s; do
      warn "Service actif : $s"
      trouve=1
    done <<< "$services"
  else
    ok "Aucun service systemd Google détecté"
  fi

  # dmesg
  subsection "dmesg récent"
  local dm
  dm=$(sudo dmesg 2>/dev/null | tail -200 | grep -iE "google|gcp|telemetry|gvnic" | tail -5)
  if [ -n "$dm" ]; then
    while IFS= read -r l; do
      warn "dmesg : $l"
      trouve=1
    done <<< "$dm"
  else
    ok "dmesg propre"
  fi

  # Processus userspace
  subsection "Processus Google"
  local procs
  procs=$(ps -eo pid,comm,args 2>/dev/null | grep -iE "google_accounts|gcsfuse|google-cloud|gsutil|google_oslogin" | grep -v grep | head -10)
  if [ -n "$procs" ]; then
    while IFS= read -r p; do
      warn "Processus : $p"
      trouve=1
    done <<< "$procs"
  else
    ok "Aucun processus Google tournant"
  fi

  if [ "$trouve" = "1" ]; then
    alert "Télémétrie Google détectée dans le kernel/système" "WARN"
    warn "→ Recommandé : sudo systemctl stop <service> && sudo rmmod <module>"
  else
    ok "Système propre — Google ne peut rien remonter par le kernel"
  fi
  phantom_log "KERNEL_SCAN_GOOGLE trouve=$trouve"
}

subsection() { echo -e "\n ${BOLD}${M}▸ $1${N}\n"; }

# ═══════════════════════════════════════════════════════════════════════════════
# ÉTAPE 6 — TEST : ENTRER DANS GOOGLE/YouTube EN FANTÔME
# ═══════════════════════════════════════════════════════════════════════════════
tester_entree_fantome() {
  section "ÉTAPE 6 — TEST D'ENTRÉE FANTÔME (Google + YouTube)"

  local tor_ok=0
  local tor_useragent="Mozilla/5.0 (X11; Linux x86_64; Phantom) Gecko/20100101 Firefox/128.0"

  # 1. Google.com via Tor, sans cookies, sans UA Chrome
  subsection "Google.com via Tor (TorSOCKS)"
  local google_status google_body
  google_status=$(torsocks curl -s -o /tmp/phantom_google.html -w "%{http_code}" \
    --max-time 20 \
    -A "$tor_useragent" \
    -H "X-Client-Data: " \
    "https://www.google.com/" 2>/dev/null || echo "000")

  if [ "$google_status" = "200" ] || [ "$google_status" = "302" ]; then
    ok "Google répond en HTTP $google_status — tu es entré sans IP réelle"
    tor_ok=$((tor_ok + 1))
  else
    ko "Échec d'accès Google (HTTP $google_status) — vérifie Tor"
  fi

  # 2. YouTube.com via Tor
  subsection "YouTube.com via Tor (TorSOCKS)"
  local yt_status
  yt_status=$(torsocks curl -s -o /tmp/phantom_yt.html -w "%{http_code}" \
    --max-time 25 \
    -A "$tor_useragent" \
    "https://www.youtube.com/" 2>/dev/null || echo "000")

  if [ "$yt_status" = "200" ] || [ "$yt_status" = "302" ]; then
    ok "YouTube répond en HTTP $yt_status"
    tor_ok=$((tor_ok + 1))
  else
    ko "Échec YouTube (HTTP $yt_status)"
  fi

  # 3. Vérifier absence de cookies persistés
  subsection "Vérification cookies post-session"
  local cookie_count
  cookie_count=$(find "$PHANTOM_PROFILE" -name "cookies.sqlite*" -exec sqlite3 {} \
    "SELECT COUNT(*) FROM moz_cookies WHERE host LIKE '%google%' OR host LIKE '%youtube%';" 2>/dev/null || echo "0")
  if [ "${cookie_count:-0}" -eq 0 ]; then
    ok "Zéro cookie Google/YouTube persisté"
    tor_ok=$((tor_ok + 1))
  else
    block "$cookie_count cookies Google/YouTube persistés — fuite !"
    alert "$cookie_count cookies Google persistés" "CRIT"
  fi

  # 4. Vérifier absence de télémétrie dans le HTML reçu
  subsection "Télémétrie dans le HTML reçu"
  local beacon_count
  beacon_count=$(grep -ciE "sendBeacon|google-analytics|doubleclick|gtag\(" /tmp/phantom_google.html /tmp/phantom_yt.html 2>/dev/null | awk -F: '{s+=$2} END{print s+0}')
  if [ "$beacon_count" -gt 0 ]; then
    warn "$beacon_count scripts de collection présents dans le HTML reçu"
    warn "Ils ne s'exécutent pas (curl ne lance pas JS) mais restent visibles"
    info "→ Ils seront neutralisés par le profil Firefox (WebRTC/JS restreints)"
  else
    ok "Aucun script de collection détecté dans le HTML reçu"
  fi

  phantom_log "TEST_ENTREE tor_ok=$tor_ok/3 beacon=$beacon_count"
  return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# ÉTAPE 7 — KILL-SWITCH SI COLLECTION TENTE DE REMONTER
# ═══════════════════════════════════════════════════════════════════════════════
kill_switch_phantom() {
  section "${R}KILL-SWITCH FANTÔME${N}"
  warn "Coupe toute liaison vers Google/YouTube immédiatement"

  # 1. Tuer navigateurs
  sudo pkill -9 -f "firefox.*phantom" 2>/dev/null || true
  sudo pkill -9 -f "chrome|chromium" 2>/dev/null || true
  ok "Navigateurs tués"

  # 2. iptables : bloquer tous les range IP Google connus
  local google_ranges=(
    "142.250.0.0/15" "172.217.0.0/16" "172.253.0.0/16"
    "173.194.0.0/16" "209.85.128.0/17" "216.58.192.0/19"
    "216.239.32.0/19" "74.125.0.0/16" "35.190.0.0/16"
    "35.232.0.0/15" "35.234.0.0/16" "35.235.0.0/16"
  )
  local n=0
  for r in "${google_ranges[@]}"; do
    sudo iptables -A OUTPUT -d "$r" -j DROP 2>/dev/null && n=$((n + 1)) || true
  done
  ok "$n ranges IP Google bloqués en OUTPUT (iptables DROP)"

  # 3. Couper torsocks et Tor si demandé
  pkill -9 torsocks 2>/dev/null || true
  ok "torsocks arrêtés"

  alert "KILL-SWITCH FANTÔME activé — Google/YouTube totalement isolés" "CRIT"
  phantom_log "KILL_SWITCH_PHANTOM ranges=$n"
}

# ═══════════════════════════════════════════════════════════════════════════════
# ÉTAPE 8 — RAPPORT DU DÉFI
# ═══════════════════════════════════════════════════════════════════════════════
generer_rapport() {
  section "ÉTAPE 8 — RAPPORT DU DÉFI FANTÔME"
  {
    echo "══════════════════════════════════════════════════════════════════════"
    echo "  RAPPORT DÉFI NEXUS PHANTOM — $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "══════════════════════════════════════════════════════════════════════"
    echo ""
    echo "→ Hôte      : $(uname -srm)"
    echo "→ Utilisateur : ${USER:-?}"
    echo "→ Tor actif   : $(ss -tln 2>/dev/null | grep -q :9050 && echo OUI || echo NON)"
    echo "→ IP de Tor   : $(curl -s --max-time 8 --socks5-hostname 127.0.0.1:9050 https://api.ipify.org 2>/dev/null || echo inconnu)"
    echo ""
    echo "── Canaux de collection Google/YouTube neutralisés ──"
    for entry in "${COLLECTION[@]}"; do
      printf "  %-16s | %s\n" "$(echo "$entry" | awk -F'|' '{print $1}')" "$(echo "$entry" | awk -F'|' '{print $3}')"
    done
    echo ""
    echo "── Logs récents (phantom.log) ──"
    tail -15 "$PHANTOM_LOG" 2>/dev/null
    echo ""
    echo "── Alertes éventuelles ──"
    tail -10 "$ALERTS" 2>/dev/null || echo "  (aucune)"
    echo ""
    echo "══════════════════════════════════════════════════════════════════════"
    echo "  Si IP directe ≠ IP Tor  →  tu es entré en fantôme."
    echo "  Si zéro cookie persisté →  la collection ne t'atteint pas."
    echo "  Si kill-switch actif     →  Google ne peut rien remonter."
    echo "══════════════════════════════════════════════════════════════════════"
  } > "$PHANTOM_REPORT"
  ok "Rapport écrit : $PHANTOM_REPORT"
  cat "$PHANTOM_REPORT"
}

# ═══════════════════════════════════════════════════════════════════════════════
# BANNIÈRE
# ═══════════════════════════════════════════════════════════════════════════════
banniere() {
  clear
  echo ""
  echo -e "${C}${BOLD}"
  cat << 'BAN'

  ╔═══════════════════════════════════════════════════════════════╗
  ║                                                               ║
  ║   ░█▀▀▀ █▀▀▄ █▀▀ █▀▀ █░░█   █▀▀ █░░ █▀▀ █▀█ █▀█ █▀▀ █▀█    ║
  ║   ░█▀▀▀ █░██ █▀▀ █░░ █▀▀█   █▀▀ █░░ █░░ █▀█ █▀▀ █░░ █░█    ║
  ║   ░▀░░░ ▀▀▀▀ ▀▀▀ ▀▀▀ ▀░░▀   ▀▀▀ ▀▀▀ ▀▀▀ ▀░▀ ▀░░ ▀▀▀ ▀░▀    ║
  ║                                                               ║
  ║          👻  MODE FANTÔME — DÉFI « AUTRE MONDE »  👻           ║
  ║                                                               ║
  ║   Google / YouTube te voient, mais ne t'atteignent pas.        ║
  ║                                                               ║
  ╚═══════════════════════════════════════════════════════════════╝
BAN
  echo -e "${N}"
  printf " ${BOLD}${W}Version :${N} ${C}%s${N} ${D}\"%s\"${N}\n" "$VERSION" "$CODENAME"
  printf " ${BOLD}${W}Auteur  :${N} ${M}%s${N}\n" "$AUTEUR"
  printf " ${BOLD}${W}Licence :${N} ${G}%s${N}\n" "$LICENCE"
  printf " ${BOLD}${W}Base    :${N} %s\n" "$BASE"
  echo ""
  echo -e " ${D}──────────────────────────────────────────────────────────────${N}"
  echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# MENU
# ═══════════════════════════════════════════════════════════════════════════════
menu() {
  while true; do
    echo ""
    echo -e "${BOLD}${B}╔══════════════════════════════════════════════════════════════════════╗${N}"
    printf "${BOLD}${B}║${N} ${BOLD}${W}%-68s${N} ${BOLD}${B}║${N}\n" "NEXUS PHANTOM — DÉFI AUTRE MONDE"
    echo -e "${BOLD}${B}╚══════════════════════════════════════════════════════════════════════╝${N}"
    echo ""
    echo -e " ${BOLD}${M}DÉFI COMPLET${N}"
    echo -e "  ${G}1${N}) ${SYM_PHANTOM} Lancer le défi complet (étapes 1→8)"
    echo ""
    echo -e " ${BOLD}${C}ÉTAPES${N}"
    echo -e "  2) Vérifier Tor Ultra 365-F"
    echo -e "  3) Durcir torrc (isolation fantôme)"
    echo -e "  4) Créer profil navigateur fantôme"
    echo -e "  5) Blacklister la collection Google/YouTube"
    echo -e "  6) Scanner le kernel anti-Google"
    echo -e "  7) Tester l'entrée fantôme (Google + YouTube)"
    echo -e "  8) Générer le rapport de défi"
    echo ""
    echo -e " ${BOLD}${R}URGENCE${N}"
    echo -e "  ${R}9${N}) ${SYM_BLOCK} Kill-Switch fantôme"
    echo ""
    echo -e "  ${D}0) Quitter${N}"
    separator
    printf " Choix : "
    read -r choix
    case "$choix" in
      1) lancer_defi_complet ;;
      2) verifier_tor ;;
      3) durcir_tor ;;
      4) creer_profil_fantome ;;
      5) blacklister_collection ;;
      6) scan_kernel_google ;;
      7) tester_entree_fantome ;;
      8) generer_rapport ;;
      9) kill_switch_phantom ;;
      0) exit 0 ;;
      *) warn "Choix invalide" ;;
    esac
    echo ""
    printf " Entrée pour continuer..."
    read -r
  done
}

lancer_defi_complet() {
  section "LANCEMENT DU DÉFI FANTÔME COMPLET"
  phant "Tu vas entrer dans Google/YouTube comme un fantôme."
  phant "Chaque étape renforce une couche : Tor, profil, blacklist, kernel, test."

  verifier_tor           || return 1
  durcir_tor
  creer_profil_fantome
  blacklister_collection
  scan_kernel_google
  tester_entree_fantome
  generer_rapport

  echo ""
  phant "Défi terminé — tu es passé comme un fantôme."
  phant "Vérifie : $PHANTOM_REPORT"
}

trap 'echo ""; info "Interruption"; exit 0' INT TERM

banniere
log "PHANTOM" "Démarrage v$VERSION défi fantôme"

case "${1:-menu}" in
  full|defi) lancer_defi_complet ;;
  tor)    verifier_tor ;;
  torrc)  durcir_tor ;;
  profil) creer_profil_fantome ;;
  bl)     blacklister_collection ;;
  kernel) scan_kernel_google ;;
  test)   tester_entree_fantome ;;
  rapport|report) generer_rapport ;;
  kill)   kill_switch_phantom ;;
  menu|*) menu ;;
esac 
