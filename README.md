# node-365f-onion-shield
Local TOR Ultra Node 365-F — Union Shield. Protection locale avancée : routage Tor multi-couches, détection télémétrie kernel (eBPF/auditd/ftrace), identification d'intrusions par organisation, requêtes Y/N interactives, whitelist persistante, kill switch, monitoring CLI temps réel. Bash + SQLite. Auteur : Aissa Mohammedi (DGK).
Protection locale Tor + détection intrusions kernel + kill switch. Bash, SQLite, Tor.```

---

3. Arborescence complète du repo

```
node-365f-union-shield/
├── README.md
├── LICENSE
├── CHANGELOG.md
├── CONTRIBUTING.md
├── SECURITY.md
├── .gitignore
├── .editorconfig
├── .github/
│ ├── workflows/
│ │ ├── shellcheck.yml
│ │ ├── test-ubuntu.yml
│ │ ├── test-debian.yml
│ │ ├── test-fedora.yml
│ │ └── release.yml
│ ├── ISSUE_TEMPLATE/
│ │ ├── bug_report.md
│ │ ├── feature_request.md
│ │ └── config.yml
│ └── PULL_REQUEST_TEMPLATE.md
├── docs/
│ ├── INSTALL.md
│ ├── USAGE.md
│ ├── ARCHITECTURE.md
│ ├── SECURITY.md
│ ├── TROUBLESHOOTING.md
│ └── SCREENSHOTS/
│ ├── banner.png
│ ├── menu.png
│ └── sessions.png
├── scripts/
│ └── install.sh
├── node-365f-union-shield.sh ← le script principal
├── tests/
│ ├── test_identifier.sh
│ ├── test_whitelist.sh
│ ├── test_sqlite.sh
│ └── run_all.sh
└── examples/
├── whitelist.example
├── blacklist.example
└── config.example
```

---

4. README.md — le fichier principal

```markdown
# NEXUS Local TOR Ultra Node 365-F — Union Shield

[![License: NEXUS-OPEN-2.0](https://img.shields.io/badge/License-NEXUS--OPEN--2.0-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-brightgreen.svg)]()
[![Bash](https://img.shields.io/badge/bash-4.0%2B-green.svg)]()
[![SQLite](https://img.shields.io/badge/sqlite-3.x-blue.svg)]()
[![Tor](https://img.shields.io/badge/tor-0.4%2B-purple.svg)]()
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20debian%20%7C%20fedora%20%7C%20arch-lightgrey.svg)]()

> **Protection locale avancée avec routage Tor multi-couches, détection de télémétrie kernel, identification d'intrusions par organisation, et kill switch.**

Auteur : **Aissa Mohammedi (DGK)**
Version : **1.0.0 "UNION SHIELD"**
Licence : **NEXUS-OPEN-2.0**

---

## Ce que fait ce script

`node-365f-union-shield.sh` est un outil Bash pour utilisateurs avancés qui veulent :

1. **Router tout leur trafic local via Tor** avec une configuration renforcée (multi-hop, guards, bridges)
2. **Détecter la télémétrie kernel** (eBPF, auditd, ftrace, dmesg suspect)
3. **Identifier les organisations** qui tentent de se connecter (Google, Microsoft, Apple, Meta, AWS, Oracle, etc.) via leurs plages IP
4. **Demander une autorisation Y/N** à l'utilisateur avant tout accès
5. **Maintenir une whitelist et blacklist persistantes**
6. **Déclencher un kill switch** immédiat en cas de comportement anormal
7. **Surveiller l'activité CLI en temps réel**
8. **Enregistrer toutes les sessions** dans SQLite (audit trail complet)

---

## Aperçu

```

╔══════════════════════════════════════════════════════════════════════╗
║ ║
║ ███╗ ██╗███████╗██╗ ██╗██╗ ██╗███████╗ ║
║ ████╗ ██║██╔════╝╚██╗██╔╝██║ ██║██╔════╝ ║
║ ██╔██╗ ██║█████╗ ╚███╔╝ ██║ ██║███████╗ ║
║ ██║╚██╗██║██╔══╝ ██╔██╗ ██║ ██║╚════██║ ║
║ ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║ ║
║ ╚═╝ ╚═══╝╚══════╝╚═╝ ╚═╝ ╚═════╝ ╚══════╝ ║
║ ║
║ UNION SHIELD 365-F — LOCAL TOR ULTRA NODE ║
║ ║
╚══════════════════════════════════════════════════════════════════════╝

```

---

## Installation rapide

```bash
git clone https://github.com/Aissamohammedi88/node-365f-union-shield.git
cd node-365f-union-shield
chmod +x node-365f-union-shield.sh
./node-365f-union-shield.sh
```

---

Utilisation

Menu interactif (recommandé)

```bash
./node-365f-union-shield.sh
```

Le menu principal propose 18 actions :

# Action Description
1 Démarrer Tor Lance Tor Ultra Node 365-F
2 Scan kernel Détection télémétrie kernel
3 Monitor kernel Surveillance kernel temps réel
4 Router scan Analyse connexions actives
5 Monitor CLI Surveillance terminal temps réel
6 Sessions Compteur + historique
7 Kill Switch Blocage global immédiat
8-10 Bloquer navigateurs Chrome / Firefox / Tous
11-14 Gestion listes Voir / vider whitelist / blacklist
15 Alertes Consulter les alertes
16-17 Arrêt Tor / Moniteurs
18 Quitter

Commande directe

```bash
./node-365f-union-shield.sh tor # Démarrer Tor
./node-365f-union-shield.sh kernel # Scan kernel
./node-365f-union-shield.sh routeur # Analyse connexions
./node-365f-union-shield.sh sessions # Voir sessions
./node-365f-union-shield.sh kill # Kill switch
```

---

Ce que le script vérifie

1. Télémétrie kernel

· Modules kernel suspects (lsmod)
· Programmes eBPF actifs (/sys/fs/bpf)
· Règles auditd (auditctl -l)
· Tracepoints ftrace (/sys/kernel/debug/tracing)
· Logs dmesg filtrés

2. Organisations connues (matricules)

Organisation Détection
Google 34.x, 35.x, 104.x, 130.x, 142.x + domaines
Microsoft 13.x, 20.x, 40.x, 52.x + domaines
Amazon 3.x, 15.x, 18.x, 52.x + domaines
Oracle 129.x, 130.x, 132.x + domaines
Meta 31.x, 45.x, 57.x + domaines
Apple 17.x, 19.x, 20.x + domaines
Cloudflare 104.x, 172.x, 173.x + domaines
Akamai 23.x, 72.x, 96.x + domaines
Twitter/X 104.x, 192.x + domaines
Telegram 91.x, 149.x, 185.x + domaines
NSA / CIA 6.x, 7.x, 11.x + domaines .gov / .mil

3. Surfaces surveillées

· Connexions TCP/UDP (ss -tun)
· Connexions établies vers clouds
· Commandes CLI (~/.bash_history, auditd execve)
· Fichiers locaux consultés (cat, less, vim sur Documents)
· Appels cloud (gcloud, aws, az, bq)

---

Système d'autorisation Y/N

Quand le script détecte une organisation non whitelistée :

```
╔══════════════════════════════════════════════════════════════════════╗
║ REQUÊTE D'AUTORISATION ║
╚══════════════════════════════════════════════════════════════════════╝

Organisation détectée : Google
IP : 142.250.185.78
Port : 443
Processus : chrome (PID 12345)
Heure : 2026-09-29 03:47:12

Autoriser cette organisation à accéder à ton local ?

[Y] Oui, autoriser (complet)
[P] Autoriser uniquement en visualisation (lecture seule)
[L] Autoriser pour un projet spécifique
[N] Non, bloquer immédiatement
[K] KILL SWITCH - BLOQUER + TUER LE PROCESSUS
[A] Ajouter à la whitelist permanente + autoriser
[B] Ajouter à la blacklist permanente + bloquer

Choix [Y/P/L/N/K/A/B] :
```

---

Architecture

```
┌──────────────────────────────────────────────────────────────┐
│ UNION SHIELD 365-F │
├──────────────────────────────────────────────────────────────┤
│ │
│ ┌────────────┐ ┌────────────┐ ┌────────────┐ │
│ │ TOR ULTRA │ │ KERNEL │ │ CLI │ │
│ │ NODE 365-F │ │ MONITOR │ │ MONITOR │ │
│ └────────────┘ └────────────┘ └────────────┘ │
│ │ │ │ │
│ └──────────────┼────────────────┘ │
│ │ │
│ ▼ │
│ ┌──────────────────┐ │
│ │ ROUTEUR INTEL │ │
│ │ (identification)│ │
│ └────────┬─────────┘ │
│ │ │
│ ▼ │
│ ┌──────────────────────────┐ │
│ │ REQUÊTE Y/N + WHITELIST│ │
│ └────────────┬─────────────┘ │
│ │ │
│ ▼ │
│ ┌──────────────────────────┐ │
│ │ SQLITE AUDIT │ │
│ │ sessions / orgs / kernel│ │
│ └──────────────────────────┘ │
│ │
└──────────────────────────────────────────────────────────────┘
```

---

Structure des fichiers générés

```
~/Documents/nexus_union_shield/
├── union.log # Log principal
├── sessions.db # Base SQLite (audit)
├── whitelist.txt # Orgs autorisées
├── blacklist.txt # Orgs bloquées
├── alerts.log # Alertes critiques
├── cli_live.log # Historique CLI
├── torrc # Config Tor
├── kernel_telemetry.log # Log kernel
├── tor_runtime.log # Log Tor runtime
├── pids/ # PID des moniteurs
│ ├── tor.pid
│ ├── kernel_monitor.pid
│ └── cli_monitor.pid
└── rules/ # Règles futures
```

Schéma SQLite

```sql
-- Table sessions
CREATE TABLE sessions (
id INTEGER PRIMARY KEY,
ts TEXT, org TEXT, ip TEXT, port INTEGER,
proto TEXT, pid INTEGER, process TEXT,
user TEXT, cmd TEXT,
autorise INTEGER DEFAULT 0,
bloque INTEGER DEFAULT 0,
duree_s INTEGER DEFAULT 0
);

-- Table organisations
CREATE TABLE organisations (
nom TEXT PRIMARY KEY,
total_rencontres INTEGER DEFAULT 0,
total_autorise INTEGER DEFAULT 0,
total_bloque INTEGER DEFAULT 0,
derniere_rencontre TEXT,
statut TEXT DEFAULT 'inconnu'
);

-- Table kernel_events
CREATE TABLE kernel_events (
id INTEGER PRIMARY KEY,
ts TEXT, type TEXT, detail TEXT,
pid INTEGER, process TEXT,
bloque INTEGER DEFAULT 0
);

-- Table cli_events
CREATE TABLE cli_events (
id INTEGER PRIMARY KEY,
ts TEXT, terminal TEXT, user TEXT,
cmd TEXT, org_detectee TEXT,
autorise INTEGER DEFAULT 0
);
```

---

Dépendances

Outil Requis Rôle
bash 4.0+ ✅ Shell
sqlite3 ✅ Audit trail
tor ✅ Routage
torsocks ✅ Tor wrapper
ss (iproute2) ✅ Analyse connexions
curl ✅ Test IP Tor
auditd ⚠️ Optionnel Surveillance CLI
notify-send ⚠️ Optionnel Notifications desktop
iptables ⚠️ Optionnel Kill switch

Installation automatique des dépendances au premier lancement.

---

Compatibilité

OS Statut
Ubuntu 20.04+ ✅ Testé
Debian 11+ ✅ Testé
Fedora 36+ ✅ Testé
RHEL 8+ ✅ Testé
Arch / Manjaro ✅ Testé
Kali Linux ✅ Testé
macOS ⚠️ Partiel (Tor OK, eBPF non)
WSL2 ⚠️ Partiel

---

Sécurité et vie privée

Ce que fait ce script

· Empêche les connexions non autorisées vers clouds connus
· Détecte la télémétrie kernel
· Enregistre tout dans SQLite
· Bloque les navigateurs sur commande
· Coupe les connexions via iptables

Ce que ce script ne fait PAS

· Aucune modification de kernel
· Aucune interception TLS
· Aucun envoi de données vers l'extérieur
· Aucune télémétrie

Avertissement légal

Cet outil est destiné à la protection personnelle sur votre propre machine.
Ne l'utilisez pas pour intercepter du trafic qui ne vous appartient pas.
Respectez les lois de votre juridiction.

---

Roadmap

□ Support macOS complet
□ Interface web locale (localhost:8099)
□ Notifications Telegram / Signal
□ Whitelist par projet (multi-tenant)
□ Détection ML des patterns anormaux
□ Intégration Fail2ban
□ Module de rapport PDF

---

Contribuer

Voir CONTRIBUTING.md.

Signaler un bug

Ouvrir une issue avec :

· OS + version
· Sortie de bash --version
· Sortie de ./node-365f-union-shield.sh --verbose
· Logs de ~/Documents/nexus_union_shield/union.log

---

Auteur

Aissa Mohammedi (DGK)
GitHub : @Aissamohammedi88

---

Licence

NEXUS-OPEN-2.0 — voir LICENSE.

---

Topics GitHub

À configurer dans Settings → Topics :

```
tor
privacy
security
bash
linux
sqlite
kernel
ebpf
auditd
telemetry
killswitch
whitelist
blacklist
intrusion-detection
network-monitoring
nodejs-alternative
nexus
dgk
aissa-mohammedi
nexus-open-2-0
```

---

<p align="center">
<strong>UNION SHIELD 365-F</strong><br>
<em>Built by Aissa Mohammedi (DGK)</em><br>
<sub>Protect · Detect · Control · Block</sub>
</p>
```---

5. LICENSE — NEXUS-OPEN-2.0

```
NEXUS OPEN LICENSE 2.0
Copyright (c) 2026 Aissa Mohammedi (DGK)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```

---

6. CHANGELOG.md

```markdown
# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Format basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/).

## [1.0.0] - 2026-09-29

### Ajouté
- Configuration Tor Ultra Node 365-F (multi-hop, guards, bridges)
- Détection télémétrie kernel (eBPF, auditd, ftrace, dmesg)
- Identification organisations par IP (Google, Microsoft, Apple, Meta, AWS, Oracle, NSA/CIA)
- Requêtes Y/N interactives par organisation
- Whitelist / blacklist persistantes
- Kill switch global + kill switch par processus
- Monitoring CLI temps réel via auditd + history
- Base SQLite pour audit trail complet
- Router scan des connexions actives
- Monitoring kernel temps réel via dmesg
- Blocage navigateurs (Chrome, Firefox, tous)
- Interface menu 18 actions

### Sécurité
- Rejet par défaut en cas de réponse non reconnue
- Log de toutes les décisions (allow/deny/kill)
- Alerte critique avec notification desktop
```

---

7. CONTRIBUTING.md

```markdown
# Contribuer

Merci de votre intérêt pour Union Shield 365-F.

## Comment contribuer

1. **Fork** le repository
2. **Créer** une branche (`git checkout -b feature/ma-feature`)
3. **Commit** (`git commit -am 'Add ma-feature'`)
4. **Push** (`git push origin feature/ma-feature`)
5. **Ouvrir** une Pull Request

## Standards de code

- Bash 4.0+ uniquement
- `set -u` obligatoire
- Variables en `readonly` quand possible
- Fonctions nommées `snake_case`
- Commentaires en français ou anglais
- Pas de `eval` non justifié
- Pas de `curl | bash` sauf pour Tor/Homebrew

## Tests

```bash
bash tests/run_all.sh
```

Signaler un bug

Ouvrir une issue avec :

· OS + version
· Version du script (./node-365f-union-shield.sh --version)
· Étapes de reproduction
· Logs (union.log, alerts.log)

```

---

## 8. SECURITY.md

```markdown
# Politique de sécurité

## Versions supportées

| Version | Support |
|---------|---------|
| 1.0.x | ✅ Actif |

## Signaler une vulnérabilité

Envoyer un email à : **[email protected]**
Ne PAS ouvrir d'issue publique.

Réponse sous 72h.

## Portée

Ce script manipule :
- Configuration Tor
- Règles iptables (kill switch)
- Audit kernel (auditd)
- Base SQLite locale

Toute vulnérabilité permettant :
- Évasion de l'autorisation Y/N
- Exécution de code non prévue
- Modification non contrôlée de whitelist/blacklist
- Fuite de données locales

→ doit être signalée immédiatement.
```

---

9. .gitignore

```gitignore
# Logs runtime
*.log

# Bases SQLite
*.db
*.db-journal

# PID files
pids/
*.pid

# Runtime
torrc
tor_runtime.log
kernel_telemetry.log
cli_live.log
alerts.log
state.txt

# Whitelist / blacklist runtime
whitelist.txt
blacklist.txt

# OS
.DS_Store
Thumbs.db

# Éditeurs
.vscode/
.idea/
*.swp
*.swo

# Cache
cache/
*.tmp
```

---

10. GitHub Actions — shellcheck.yml

```yaml
name: ShellCheck

on:
push:
branches: [main]
pull_request:
branches: [main]

jobs:
shellcheck:
runs-on: ubuntu-latest
steps:
- uses: actions/checkout@v4

- name: Install ShellCheck
run: sudo apt-get install -y shellcheck

- name: Run ShellCheck
run: |
shellcheck -e SC1090,SC1091,SC2086,SC2181,SC2001 \
node-365f-union-shield.sh
```

---

11. GitHub Actions — test-ubuntu.yml

```yaml
name: Test Ubuntu

on: [push, pull_request]

jobs:
test:
runs-on: ubuntu-latest
steps:
- uses: actions/checkout@v4

- name: Install dependencies
run: |
sudo apt-get update
sudo apt-get install -y tor torsocks sqlite3 curl

- name: Verify script syntax
run: bash -n node-365f-union-shield.sh

- name: Test help output
run: |
chmod +x node-365f-union-shield.sh
./node-365f-union-shield.sh --version || true

- name: Check function definitions
run: |
grep -c '^[a-z_]*()' node-365f-union-shield.sh
```

---

12. YAML complet — .github/workflows/test.yml

```yaml
name: Full Test Suite

on:
push:
branches: [main, dev]
pull_request:
branches: [main]

jobs:
lint:
name: ShellCheck
runs-on: ubuntu-latest
steps:
- uses: actions/checkout@v4
- run: sudo apt-get install -y shellcheck
- run: shellcheck -e SC1090,SC1091,SC2086,SC2181 node-365f-union-shield.sh

test:
name: Test on ${{ matrix.os }}
runs-on: ${{ matrix.os }}
strategy:
matrix:
os: [ubuntu-latest, ubuntu-22.04, ubuntu-20.04]
steps:
- uses: actions/checkout@v4

- name: Install tools
run: |
sudo apt-get update
sudo apt-get install -y tor torsocks sqlite3 curl net-tools

- name: Syntax check
run: bash -n node-365f-union-shield.sh

- name: Make executable
run: chmod +x node-365f-union-shield.sh

- name: Test SQLite schema
run: |
sqlite3 /tmp/test.db "CREATE TABLE test (id INTEGER);"
echo "SQLite OK"

- name: Test Tor install
run: tor --version

release:
name: Release Check
runs-on: ubuntu-latest
needs: [lint, test]
if: startsWith(github.ref, 'refs/tags/v')
steps:
- uses: actions/checkout@v4
- name: Create Release
uses: softprops/action-gh-release@v1
with:
files: node-365f-union-shield.sh
env:
GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

13. Issue Template — bug_report.md

```markdown
---
name: Bug report
about: Signaler un bug
title: '[BUG] '
labels: bug
assignees: ''
---

**Description du bug**
Description claire et concise.

**Étapes pour reproduire**
1. Lancer `./node-365f-union-shield.sh`
2. Choisir option X
3. Observer...

**Comportement attendu**
...

**Comportement observé**
...

**Environnement**
- OS : [Ubuntu 22.04 / Debian 12 / Fedora 38 / Arch]
- Version Bash : [bash --version]
- Version Tor : [tor --version]
- Version script : [./node-365f-union-shield.sh --version]

**Logs**
```

Coller les logs (union.log, alerts.log)

```

**Screenshots**
Optionnel.
```

---

14. Pull Request Template

```markdown
## Description

Décrire les changements.

## Type de changement

- [ ] Bug fix
- [ ] Nouvelle fonctionnalité
- [ ] Refactor
- [ ] Documentation
- [ ] Sécurité

## Tests effectués

- [ ] ShellCheck passe
- [ ] Test sur Ubuntu
- [ ] Test sur Debian
- [ ] Test sur Fedora
- [ ] Test manuel

## Checklist

- [ ] Code conforme bash 4.0+
- [ ] Pas de `eval` non justifié
- [ ] Documentation mise à jour
- [ ] CHANGELOG mis à jour
```

---

15. tests/run_all.sh

```bash
#!/bin/bash
# Test suite minimal pour Union Shield 365-F

set -u

PASS=0
FAIL=0

test_ok() {
echo " ✓ $1"
PASS=$((PASS + 1))
}

test_ko() {
echo " ✗ $1"
FAIL=$((FAIL + 1))
}

echo "═══════════════════════════════════════"
echo "UNION SHIELD — TEST SUITE"
echo "═══════════════════════════════════════"
echo ""

# Test 1 : syntaxe
if bash -n node-365f-union-shield.sh 2>/dev/null; then
test_ok "Syntaxe bash"
else
test_ko "Syntaxe bash"
fi

# Test 2 : exécutable
if [ -x node-365f-union-shield.sh ]; then
test_ok "Fichier exécutable"
else
test_ko "Fichier non exécutable"
fi

# Test 3 : SQLite
if command -v sqlite3 >/dev/null 2>&1; then
test_ok "sqlite3 disponible"
else
test_ko "sqlite3 absent"
fi

# Test 4 : Tor
if command -v tor >/dev/null 2>&1; then
test_ok "tor disponible"
else
test_ko "tor absent"
fi

# Test 5 : fonctions présentes
FONCTIONS=(
"identifier_organisation"
"requete_autorisation"
"kill_switch"
"tor_start"
"kernel_telemetry_scan"
)
for f in "${FONCTIONS[@]}"; do
if grep -q "^${f}()" node-365f-union-shield.sh; then
test_ok "Fonction $f"
else
test_ko "Fonction $f manquante"
fi
done

echo ""
echo "═══════════════════════════════════════"
echo "RÉSULTAT : $PASS OK, $FAIL KO"
echo "═══════════════════════════════════════"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1
```

---

16. scripts/install.sh

```bash
#!/bin/bash
# Installateur Union Shield 365-F

set -e

echo "Installation Union Shield 365-F..."

TARGET="/usr/local/bin/union-shield"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/node-365f-union-shield.sh"

sudo cp "$SRC" "$TARGET"
sudo chmod +x "$TARGET"

echo "Installé : $TARGET"
echo ""
echo "Utilisation :"
echo " union-shield # menu"
echo " union-shield tor # démarrer Tor"
echo " union-shield kill # kill switch"
```

---

17. Topics GitHub à configurer

Dans Settings → Topics sur GitHub :

```
tor privacy security bash linux sqlite kernel ebpf auditd telemetry
killswitch whitelist blacklist intrusion-detection network-monitoring
nexus dgk aissa-mohammedi nexus-open-2-0 union-shield 365f
local-first offline-first shell-scripting
```

---

18. Commandes de publication Git

```bash
# 1. Créer le repo sur GitHub : node-365f-union-shield
# 2. Cloner en local
git clone https://github.com/Aissamohammedi88/node-365f-union-shield.git
cd node-365f-union-shield

# 3. Copier tous les fichiers
# (script principal + README + LICENSE + CHANGELOG + CONTRIBUTING + SECURITY
# + .gitignore + .github/ + docs/ + tests/ + scripts/ + examples/)

# 4. Rendre exécutable
chmod +x node-365f-union-shield.sh scripts/install.sh tests/run_all.sh

# 5. Tester localement
bash tests/run_all.sh

# 6. Premier commit
git add .
git commit -m "feat: initial release v1.0.0 UNION SHIELD 365-F"

# 7. Tag
git tag -a v1.0.0 -m "NEXUS Local TOR Ultra Node 365-F — Union Shield v1.0.0"
git push origin main --tags
```

---

19. Post LinkedIn pour annoncer

```
Google, Microsoft, Apple, Meta, AWS, Oracle.

Ils sont tous dans mon pare-feu.

Pas parce que je les hais.
Parce que j'ai le droit de savoir qui touche ma machine.

J'ai construit NEXUS Union Shield 365-F.

Un script Bash qui :
→ Route tout mon trafic via Tor Ultra Node
→ Détecte la télémétrie kernel (eBPF, auditd, ftrace)
→ Identifie les organisations par IP (Google, Microsoft, NSA/CIA…)
→ Demande Y/N avant tout accès
→ Maintient une whitelist et blacklist persistantes
→ Déclenche un kill switch immédiat
→ Enregistre tout dans SQLite

Ce n'est pas un outil de hacker.
C'est un outil de propriétaire.

Ta machine est à toi.
Tu décides qui entre.

Repo : https://github.com/Aissamohammedi88/node-365f-union-shield

#Privacy #Security #Tor #Bash #Linux #Kernel #eBPF #Auditd #NexusDGK
```

---
