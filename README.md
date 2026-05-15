# birtha - Bash Incident Response & Threat Hunt Automation
A bash-based live response and DFIR triage toolkit for macOS, Linux, and Unix-like systems.
###
Birtha is a modular Bash framework for live incident response and threat hunting on macOS, Linux, and Unix-like systems. It collects host artifacts locally or over SSH, records a structured execution manifest, normalizes common evidence, generates prioritized findings, supports analyst suppressions, and produces Markdown/HTML executive reports.

Birtha is designed for SOC analysts and incident responders who need repeatable live-response collection without installing an agent on the target host.

![alt text](https://github.com/ArronJablonowski/birtha/blob/main/img/birtha.png?raw=true)

### Html Report - Stats provide a brief overview of Birtha’s collection performance and finding volume.
##
![alt text](https://github.com/ArronJablonowski/birtha/blob/main/img/stats.png?raw=true)

### Html Report - Prioritized Findings help an analyst quickly drill down to the highest-priority evidence, the rule that triggered, and the exact artifact that needs review.
##
![alt text](https://github.com/ArronJablonowski/birtha/blob/main/img/findings.png?raw=true)

## Quick Start

Remote collection over SSH:

```bash
ssh-add ./path/to/private/key/IncidentResponse_ed25519
./birtha.sh root@hostname ./BirthaConfigs/Default_Modules.conf
```

Local collection without SSH:

```bash
./birtha.sh --local-host --profile macos-compromise
./birtha.sh --localhost ./BirthaConfigs/Triage_Linux_Unix_Compromise.conf
```

Collect and immediately open an HTML report:

```bash
./birtha.sh --post-report html root@hostname ./BirthaConfigs/Triage_SSH_Compromise.conf
./birtha.sh --post-report html --finding-limit 100 ./HostLists/hosts.txt ./BirthaConfigs/Triage_Linux_Unix_Compromise.conf
./birtha.sh --post-report html --all-findings --local-host --profile forensic-deep
```

Analyze an existing run:

```bash
./birtha-analyze.sh summarize ./Results/<timestamp>
./birtha-analyze.sh html-report ./Results/<timestamp> --all-findings
./birtha-analyze.sh bundle ./Results/<timestamp>
```

## Pre-Usage Setup

For remote collection:

- Create a dedicated SSH key pair with a strong passphrase.
- Distribute the public key to remote hosts Birtha will access.
- For complete live response, install the public key for the remote `root` account or another account with sufficient privileges.
- Run `ssh-add` before collection to avoid repeated passphrase prompts.

```bash
ssh-add ./path/to/private/key/IncidentResponse_ed25519
ssh-add ~/.ssh/ir_ed25519
```

For local collection:

- SSH is not required.
- Use `--local`, `--local-host`, or `--localhost`.
- All three switches are aliases and perform the same function.
- Modules run directly on the current host using their declared shell, such as `bash -s < module.sh` or `zsh -s < module.zsh`.

## Collection Concepts

Birtha runs module files listed in a config file. Results are written under `Results/`.

Each non-dry-run execution writes:

- `case_manifest.json`: case metadata, operator, ticket, command line, config hash, and collector host.
- `run_manifest.tsv`: tabular execution record for every module run.
- `run_manifest.jsonl`: JSONL execution record for every module run.
- `stdout.log`: collected standard output for each module.
- `stderr.txt`: errors, warnings, and timeout messages for each module.
- `meta.txt`: per-module metadata.
- `_preflight/`: host profile and dependency preflight output.

When `--case` is used, results are stored under:

```text
Results/<CASE_ID>/run_<timestamp>/
```

Without `--case`, results are stored under:

```text
Results/<timestamp>/
```

The analyzer remains compatible with older result folders that used `stdout.txt`.

## Basic Collection Examples

Run the default config against one host:

```bash
./birtha.sh root@hostname
./birtha.sh root@10.10.10.25
```

Run a specific config:

```bash
./birtha.sh root@hostname ./BirthaConfigs/Default_Modules.conf
./birtha.sh root@linux-host ./BirthaConfigs/Triage_Linux_Unix_Compromise.conf
./birtha.sh root@mac-host ./BirthaConfigs/Triage_MacOS_Initial.conf
```

Run against a host list:

```bash
./birtha.sh ./HostLists/hosts.txt ./BirthaConfigs/Default_Modules.conf
./birtha.sh ./HostLists/linux_hosts.txt ./BirthaConfigs/Triage_SSH_Compromise.conf
```

Host list files should contain one host per line:

```text
root@10.10.10.11
root@10.10.10.12
root@mac-hostname
```

Blank lines and comments are ignored.

## Curated Profiles

Profiles map analyst-friendly names to curated config files.

Available profiles:

- `fast`: network and process triage.
- `standard`: default module set.
- `macos-initial` or `macos-compromise`: initial macOS compromise triage.
- `macos-persistence`: macOS persistence-focused collection.
- `linux-ssh-compromise` or `ssh-compromise`: SSH compromise triage.
- `linux-compromise` or `unix-compromise`: broad Linux/Unix compromise triage.
- `cryptominer`: cryptominer-focused triage.
- `forensic-deep`: deeper forensic collection.

Examples:

```bash
./birtha.sh --profile fast root@hostname
./birtha.sh --profile standard ./HostLists/hosts.txt
./birtha.sh --profile macos-compromise root@mac-host
./birtha.sh --profile macos-persistence --local-host
./birtha.sh --profile linux-ssh-compromise root@linux-host
./birtha.sh --profile unix-compromise ./HostLists/unix_hosts.txt
./birtha.sh --profile cryptominer root@linux-host
./birtha.sh --profile forensic-deep --local-host
```

## Config Files

Current top-level configs include:

```text
BirthaConfigs/Default_Modules.conf
BirthaConfigs/MacOS_Modules.conf
BirthaConfigs/OpenWRT_Modules.conf
BirthaConfigs/RaspberryPi_Modules.conf
BirthaConfigs/RedHat_Modules.conf
BirthaConfigs/Triage_CryptoMiner.conf
BirthaConfigs/Triage_Forensic_Deep.conf
BirthaConfigs/Triage_Linux_Unix_Compromise.conf
BirthaConfigs/Triage_MacOS_Initial.conf
BirthaConfigs/Triage_MacOS_Persistence.conf
BirthaConfigs/Triage_Network_Processes.conf
BirthaConfigs/Triage_SSH_Compromise.conf
BirthaConfigs/Ubuntu_Modules.conf
BirthaConfigs/Unix_Network_and_Processes.conf
```

Run a config directly:

```bash
./birtha.sh root@hostname ./BirthaConfigs/Ubuntu_Modules.conf
./birtha.sh --local-host ./BirthaConfigs/Triage_MacOS_Initial.conf
./birtha.sh ./HostLists/hosts.txt ./BirthaConfigs/Triage_Forensic_Deep.conf
```

## `birtha.sh` Switch Reference

### `--dry-run`, `-dry-run`, `-n`

Preview what Birtha would run without opening SSH connections or writing a Results directory.

```bash
./birtha.sh --dry-run root@hostname ./BirthaConfigs/Default_Modules.conf
./birtha.sh -n ./HostLists/hosts.txt ./BirthaConfigs/Triage_MacOS_Initial.conf
./birtha.sh -dry-run --profile forensic-deep --local-host
```

### `--validate`

Validate host input and config/module syntax without collecting evidence.

```bash
./birtha.sh --validate ./BirthaConfigs/MacOS_Modules.conf
./birtha.sh --validate root@hostname ./BirthaConfigs/Default_Modules.conf
./birtha.sh --validate ./HostLists/hosts.txt ./BirthaConfigs/Triage_SSH_Compromise.conf
```

### `--local`, `--local-host`, `--localhost`

Run modules directly on the current host without SSH. These switches are functionally identical.

```bash
./birtha.sh --local ./BirthaConfigs/Triage_MacOS_Initial.conf
./birtha.sh --local-host --profile macos-compromise
./birtha.sh --localhost --case CASE-2026-LOCAL --operator analyst --profile forensic-deep
```

### `--list-modules`

List modules with metadata such as type, OS, category, runtime, priority, dependencies, shell, and whether the module modifies the system.

```bash
./birtha.sh --list-modules
./birtha.sh --list-modules --os macos
./birtha.sh --list-modules --category persistence
./birtha.sh --list-modules --os linux --category audit
```

### `--os <value>`

Filter `--list-modules` output by module OS metadata.

```bash
./birtha.sh --list-modules --os macos
./birtha.sh --list-modules --os linux
./birtha.sh --list-modules --os all
```

### `--category <value>`

Filter `--list-modules` output by module category metadata.

```bash
./birtha.sh --list-modules --category persistence
./birtha.sh --list-modules --category network
./birtha.sh --list-modules --category audit
```

### `--profile <name>`

Use a curated triage profile instead of manually selecting a config file.

```bash
./birtha.sh --profile fast root@hostname
./birtha.sh --profile macos-compromise --local-host
./birtha.sh --profile linux-compromise ./HostLists/linux_hosts.txt
./birtha.sh --profile forensic-deep --post-report html root@hostname
```

The `--profile=<name>` form is also supported:

```bash
./birtha.sh --profile=macos-persistence --local-host
./birtha.sh --profile=cryptominer root@linux-host
```

### `--case <case_id>`

Store results under `Results/<CASE_ID>/run_<timestamp>/` and write case metadata.

```bash
./birtha.sh --case CASE-2026-001 root@hostname ./BirthaConfigs/Default_Modules.conf
./birtha.sh --case INC-1042 --local-host --profile macos-compromise
./birtha.sh --case RANSOM-2026-05 ./HostLists/hosts.txt ./BirthaConfigs/Triage_Forensic_Deep.conf
```

The `--case=<case_id>` form is also supported.

### `--operator <name>`

Record the analyst/operator name in `case_manifest.json`.

```bash
./birtha.sh --operator analyst root@hostname
./birtha.sh --operator "Jane Analyst" --case CASE-2026-001 root@hostname
./birtha.sh --operator soc-tier2 --local-host --profile forensic-deep
```

The `--operator=<name>` form is also supported.

### `--ticket <ticket_id>`

Record a ticket or incident identifier in `case_manifest.json`.

```bash
./birtha.sh --ticket INC-1042 root@hostname
./birtha.sh --case CASE-2026-001 --ticket SEC-7781 ./HostLists/hosts.txt
./birtha.sh --ticket RITM0000123 --operator analyst --local-host
```

The `--ticket=<ticket_id>` form is also supported.

### `--notes <text>`

Record analyst notes in `case_manifest.json`.

```bash
./birtha.sh --notes "Initial triage after EDR alert" root@hostname
./birtha.sh --notes "Local macOS persistence review" --local-host --profile macos-persistence
./birtha.sh --case INC-1042 --notes "Containment not started yet" ./HostLists/hosts.txt
```

The `--notes=<text>` form is also supported.

### `--strict-host-keys`

Use strict SSH host key checking. This is recommended for high-integrity incident cases when `known_hosts` has been pre-populated.

```bash
./birtha.sh --strict-host-keys root@hostname
./birtha.sh --strict-host-keys --known-hosts ./known_hosts root@hostname
./birtha.sh --strict-host-keys --case CASE-2026-001 ./HostLists/hosts.txt
```

### `--known-hosts <path>`

Use a specific SSH known-hosts file.

```bash
./birtha.sh --known-hosts ./known_hosts root@hostname
./birtha.sh --strict-host-keys --known-hosts ./case_known_hosts ./HostLists/hosts.txt
./birtha.sh --known-hosts ./Results/CASE-2026-001/known_hosts root@hostname
```

The `--known-hosts=<path>` form is also supported.

### `--identity-file <path>`, `-i <path>`

Use a specific SSH private key for remote collection.

```bash
./birtha.sh --identity-file ~/.ssh/ir_ed25519 root@hostname
./birtha.sh -i ./ssh_keys/incident_response_ed25519 ./HostLists/hosts.txt
./birtha.sh --identity-file ./keys/case_ed25519 --strict-host-keys --known-hosts ./known_hosts root@hostname
```

The `--identity-file=<path>` form is also supported.

### `--timeout <seconds>`

Set the per-module timeout. The default is controlled by `BIRTHA_MODULE_TIMEOUT` or falls back to 60 seconds.

```bash
./birtha.sh --timeout 60 root@hostname
./birtha.sh --timeout 180 --profile forensic-deep ./HostLists/hosts.txt
./birtha.sh --timeout=30 --local-host --profile fast
```

Environment variable example:

```bash
BIRTHA_MODULE_TIMEOUT=120 ./birtha.sh root@hostname ./BirthaConfigs/Triage_Forensic_Deep.conf
```

### `--max-jobs <number>`

Set the maximum number of concurrent module jobs. The default is controlled by `BIRTHA_MAX_JOBS` or falls back to 8.

```bash
./birtha.sh --max-jobs 4 ./HostLists/hosts.txt ./BirthaConfigs/Default_Modules.conf
./birtha.sh --max-jobs 16 ./HostLists/large_host_list.txt ./BirthaConfigs/Triage_Network_Processes.conf
./birtha.sh --max-jobs=2 --profile forensic-deep root@hostname
```

Environment variable example:

```bash
BIRTHA_MAX_JOBS=12 ./birtha.sh ./HostLists/hosts.txt ./BirthaConfigs/Triage_SSH_Compromise.conf
```

### `--allow-changes`

Allow modules that may modify the system. By default, Birtha blocks modules tagged with `BIRTHA_MODIFIES_SYSTEM=true` or modules stored under `RemediationModules/`.

Use this carefully. Live response collection should normally remain read-only.

```bash
./birtha.sh --allow-changes root@hostname ./BirthaConfigs/System_Setup_Config/disable_sshd_welcome_message_Ubuntu.conf
./birtha.sh --allow-changes --case REMEDIATE-001 root@hostname ./BirthaConfigs/System_Setup_Config/enable_sshd_welcome_message_Ubuntu.conf
./birtha.sh --allow-changes --validate root@hostname ./BirthaConfigs/System_Setup_Config/disable_sshd_welcome_message_RedHat.conf
```

### `--resume <Results/run_dir>`

Continue writing to a previous Results directory.

```bash
./birtha.sh --resume ./Results/CASE-2026-001/run_2026_05_14_180000-0600 root@hostname ./BirthaConfigs/Triage_SSH_Compromise.conf
./birtha.sh --resume ./Results/CASE-2026-001/run_2026_05_14_180000-0600 ./HostLists/hosts.txt ./BirthaConfigs/Triage_Forensic_Deep.conf
./birtha.sh --resume ./Results/old_run --operator analyst --ticket INC-1042 root@hostname
```

The `--resume=<Results/run_dir>` form is also supported.

### `--retry-failed`

When used with `--resume`, retry modules that previously failed instead of skipping all completed modules.

```bash
./birtha.sh --resume ./Results/CASE-2026-001/run_2026_05_14_180000-0600 --retry-failed root@hostname ./BirthaConfigs/Triage_SSH_Compromise.conf
./birtha.sh --retry-failed --resume ./Results/old_run ./HostLists/hosts.txt ./BirthaConfigs/Default_Modules.conf
./birtha.sh --resume ./Results/old_run --retry-failed --post-report html root@hostname
```

### `--no-preflight`

Skip the host preflight step. Preflight normally records host profile and dependency data under `_preflight/`.

```bash
./birtha.sh --no-preflight root@hostname ./BirthaConfigs/Default_Modules.conf
./birtha.sh --no-preflight --local-host --profile fast
./birtha.sh --no-preflight --post-report html ./HostLists/hosts.txt ./BirthaConfigs/Triage_Network_Processes.conf
```

### `--post-report <format>`

Generate a report after collection finishes, using the freshly created Results directory.

Supported formats:

- `html`: generate and open `birtha-executive-report.html`.
- `markdown`, `markdown-report`, or `md`: generate the Markdown executive report and refresh the companion HTML report.
- `report`, `executive`, or `executive-report`: generate both Markdown and HTML executive reports.

```bash
./birtha.sh --post-report html root@hostname ./BirthaConfigs/Triage_SSH_Compromise.conf
./birtha.sh --post-report markdown --local-host --profile macos-compromise
./birtha.sh --post-report report ./HostLists/hosts.txt ./BirthaConfigs/Triage_Linux_Unix_Compromise.conf
./birtha.sh --post-report=html --case CASE-2026-001 root@hostname
./birtha.sh --post-report=executive-report --finding-limit 25 ./HostLists/hosts.txt
```

If some modules fail, Birtha still generates the report and then exits with the module failure warning so automation can detect the imperfect collection.

### `--html-report`

Convenience alias for `--post-report html`.

```bash
./birtha.sh --html-report root@hostname ./BirthaConfigs/Triage_SSH_Compromise.conf
./birtha.sh --html-report --local-host --profile forensic-deep
./birtha.sh --html-report --finding-limit 100 ./HostLists/hosts.txt ./BirthaConfigs/Triage_Linux_Unix_Compromise.conf
```

### `--markdown-report`

Convenience alias for `--post-report markdown`. This writes the Markdown executive report and refreshes the companion HTML report.

```bash
./birtha.sh --markdown-report root@hostname ./BirthaConfigs/Default_Modules.conf
./birtha.sh --markdown-report --local-host --profile macos-compromise
./birtha.sh --markdown-report --all-findings ./HostLists/hosts.txt ./BirthaConfigs/Triage_Forensic_Deep.conf
```

### `--executive-report`

Convenience alias for `--post-report report`.

```bash
./birtha.sh --executive-report root@hostname ./BirthaConfigs/Triage_SSH_Compromise.conf
./birtha.sh --executive-report --local-host --profile forensic-deep
./birtha.sh --executive-report --finding-limit 25 ./HostLists/hosts.txt
```

### `--all-findings`, `--all-prioritized-findings`

Display every active prioritized finding in generated reports instead of the default top 50.

```bash
./birtha.sh --post-report html --all-findings root@hostname ./BirthaConfigs/Triage_Linux_Unix_Compromise.conf
./birtha.sh --html-report --all-prioritized-findings --local-host --profile forensic-deep
./birtha.sh --executive-report --all-findings ./HostLists/hosts.txt ./BirthaConfigs/Triage_Forensic_Deep.conf
```

Findings remain ranked by severity: critical, high, medium, low, informational.

### `--finding-limit <number>`, `--prioritized-findings-limit <number>`

Control how many prioritized findings appear in generated reports.

```bash
./birtha.sh --post-report html --finding-limit 25 root@hostname ./BirthaConfigs/Triage_SSH_Compromise.conf
./birtha.sh --html-report --finding-limit 100 ./HostLists/hosts.txt ./BirthaConfigs/Triage_Linux_Unix_Compromise.conf
./birtha.sh --executive-report --prioritized-findings-limit 10 --local-host --profile macos-persistence
```

The `--finding-limit=<number>` and `--prioritized-findings-limit=<number>` forms are also supported.

### `--help`, `-h`

Print command usage.

```bash
./birtha.sh --help
./birtha.sh -h
```

## Analyzer Command Reference

`birtha-analyze.sh` operates on completed Results directories.

### `summarize`

Print a run summary from `run_manifest.tsv`.

```bash
./birtha-analyze.sh summarize ./Results/<timestamp>
./birtha-analyze.sh summarize ./Results/CASE-2026-001/run_2026_05_14_180000-0600
```

### `failed-modules`

List modules that failed or timed out.

```bash
./birtha-analyze.sh failed-modules ./Results/<timestamp>
./birtha-analyze.sh failed-modules ./Results/CASE-2026-001/run_2026_05_14_180000-0600
```

### `suspicious-persistence`

Search persistence and audit artifacts for suspicious command patterns and persistence indicators.

```bash
./birtha-analyze.sh suspicious-persistence ./Results/<timestamp>
./birtha-analyze.sh suspicious-persistence ./Results/CASE-2026-001/run_2026_05_14_180000-0600
```

### `external-connections`

Search network and process artifacts for connection indicators.

```bash
./birtha-analyze.sh external-connections ./Results/<timestamp>
./birtha-analyze.sh external-connections ./Results/CASE-2026-001/run_2026_05_14_180000-0600
```

### `timeline`

Print a text timeline from module metadata.

```bash
./birtha-analyze.sh timeline ./Results/<timestamp>
./birtha-analyze.sh timeline ./Results/CASE-2026-001/run_2026_05_14_180000-0600
```

The HTML report timeline uses `run_manifest.tsv` and displays every module run with timestamp, status, duration, module, host, shell, transport, and output path.

### `normalize`

Create structured JSONL normalized artifacts under `Results/<run>/normalized/`.

```bash
./birtha-analyze.sh normalize ./Results/<timestamp>
./birtha-analyze.sh normalize ./Results/CASE-2026-001/run_2026_05_14_180000-0600
```

Normalized outputs include process, network, persistence, launchd, systemd, user, SSH key, browser extension, TCC, package, container, and file-integrity records where matching artifacts exist.

### `findings`

Apply rules to collected artifacts and write active/suppressed findings.

```bash
./birtha-analyze.sh findings ./Results/<timestamp>
./birtha-analyze.sh findings ./Results/<timestamp> ./Rules/default.jsonl
./birtha-analyze.sh findings ./Results/<timestamp> ./Rules/macos_persistence.jsonl
./birtha-analyze.sh findings ./Results/<timestamp> ./Rules/default.rules
```

Outputs:

- `findings.jsonl`
- `suppressed_findings.jsonl`

### `suppressed-findings`

Regenerate findings and print suppressed findings.

```bash
./birtha-analyze.sh suppressed-findings ./Results/<timestamp>
./birtha-analyze.sh suppressed-findings ./Results/<timestamp> ./Rules/linux_ssh_compromise.jsonl
./birtha-analyze.sh suppressed-findings ./Results/<timestamp> ./Rules/linux_ssh_compromise.rules
```

### `suppression-list`

List JSONL suppression database entries.

```bash
./birtha-analyze.sh suppression-list
./birtha-analyze.sh suppression-list ./Rules/finding_suppressions.jsonl
```

### `suppression-check`

Validate the suppression JSONL database format.

```bash
./birtha-analyze.sh suppression-check
./birtha-analyze.sh suppression-check ./Rules/finding_suppressions.jsonl
```

### `suppression-add`

Add an exact suppression for a generated finding ID.

```bash
./birtha-analyze.sh suppression-add ./Results/<timestamp> BIRTHA-000001 "Known-good management tool"
./birtha-analyze.sh suppression-add ./Results/<timestamp> BIRTHA-000042 "Expected admin SSH key"
```

### `rules-check`

Validate a JSONL or legacy TSV rules file.

```bash
./birtha-analyze.sh rules-check
./birtha-analyze.sh rules-check ./Rules/default.jsonl
./birtha-analyze.sh rules-check ./Rules/macos_persistence.jsonl
./birtha-analyze.sh rules-check ./Rules/default.rules
```

### `baseline`

Create a baseline from normalized artifacts.

```bash
./birtha-analyze.sh baseline ./Results/<known_good_timestamp>
./birtha-analyze.sh baseline ./Results/golden_macos_run
```

### `diff`

Compare a baseline against a current run.

```bash
./birtha-analyze.sh diff ./Results/<known_good_timestamp>/baseline ./Results/<current_timestamp>
./birtha-analyze.sh diff ./Results/golden_macos_run/baseline ./Results/suspect_macos_run
```

### `rules`

Print a compact text view of generated rule findings.

```bash
./birtha-analyze.sh rules ./Results/<timestamp>
./birtha-analyze.sh rules ./Results/<timestamp> ./Rules/macos_persistence.jsonl
./birtha-analyze.sh rules ./Results/<timestamp> ./Rules/linux_ssh_compromise.jsonl
./birtha-analyze.sh rules ./Results/<timestamp> ./Rules/macos_persistence.rules
```

### `report`

Generate both executive Markdown and HTML reports.

```bash
./birtha-analyze.sh report ./Results/<timestamp>
./birtha-analyze.sh report ./Results/<timestamp> --all-findings
./birtha-analyze.sh report ./Results/<timestamp> --finding-limit 100
```

### `markdown-report`

Generate `birtha-executive-report.md` and refresh the companion HTML report.

```bash
./birtha-analyze.sh markdown-report ./Results/<timestamp>
./birtha-analyze.sh markdown-report ./Results/<timestamp> --all-findings
./birtha-analyze.sh markdown-report ./Results/<timestamp> --finding-limit 25
BIRTHA_OPEN_REPORT=false ./birtha-analyze.sh markdown-report ./Results/<timestamp>
```

### `html-report`

Generate `birtha-executive-report.html` and open it in the default browser unless disabled. The HTML report includes collapsible finding cards, a single `Collapse All` / `Expand All` findings control, a collapsible Collection Timeline section, compact scrollable evidence windows, and highlighted matched evidence.

```bash
./birtha-analyze.sh html-report ./Results/<timestamp>
./birtha-analyze.sh html-report ./Results/<timestamp> --all-findings
./birtha-analyze.sh html-report ./Results/<timestamp> --finding-limit 100
```

Disable automatic opening:

```bash
BIRTHA_OPEN_REPORT=false ./birtha-analyze.sh html-report ./Results/<timestamp>
```

### `bundle`

Create an evidence tarball, SHA256 checksum, and evidence manifest. If GPG is available, Birtha attempts to create a detached signature.

```bash
./birtha-analyze.sh bundle ./Results/<timestamp>
./birtha-analyze.sh bundle ./Results/CASE-2026-001/run_2026_05_14_180000-0600
```

## Analyzer Report Switches

These switches work with `report`, `markdown-report`, and `html-report`.

### `--all-findings`, `--all-prioritized-findings`

Show every active prioritized finding.

```bash
./birtha-analyze.sh html-report ./Results/<timestamp> --all-findings
./birtha-analyze.sh markdown-report ./Results/<timestamp> --all-prioritized-findings
./birtha-analyze.sh report ./Results/<timestamp> --all-findings
```

### `--finding-limit <number>`, `--prioritized-findings-limit <number>`

Control the number of prioritized findings displayed in reports. Default is 50.

```bash
./birtha-analyze.sh html-report ./Results/<timestamp> --finding-limit 10
./birtha-analyze.sh markdown-report ./Results/<timestamp> --finding-limit 100
./birtha-analyze.sh report ./Results/<timestamp> --prioritized-findings-limit 25
```

The `--finding-limit=<number>` and `--prioritized-findings-limit=<number>` forms are also supported.

## Prioritized Findings

Prioritized findings are generated from rules and stored in `findings.jsonl`. Suppressed findings are stored in `suppressed_findings.jsonl`.

Rules are now JSONL-first. The default rules file is:

```text
Rules/default.jsonl
```

Legacy TSV rule files such as `Rules/default.rules`, `Rules/macos_persistence.rules`, and `Rules/linux_ssh_compromise.rules` are still supported for backward compatibility.

Legacy TSV rules do not have an explicit `os` column. Birtha infers OS scope from common rule id prefixes such as `MAC_*`, `LINUX_*`, `SSH_*`, and `SYSTEMD_*` when applying TSV rules.

JSONL rule files are preferred because each line is a self-contained detection object. This makes detections easier to review, disable, enrich, validate, and eventually manage in a UI.

JSONL rule example:

```json
{"rule_id":"LINUX_LD_PRELOAD","title":"Linux LD preload persistence or rootkit signal","enabled":true,"severity":"critical","confidence":"high","os":"linux","artifact":"persistence","scope":"*/ASEP/*","pattern":"/etc/ld.so.preload|/tmp|/dev/shm|LD_PRELOAD","mitre_attack":["TA0003","TA0005","T1574.006"],"tags":["linux","ld-preload","rootkit","persistence"],"why_it_matters":"LD preload abuse can intercept process execution and is common in userland rootkits.","false_positive_notes":"Validate approved profiling, debugging, or EDR components before remediation.","recommended_next_steps":"Preserve /etc/ld.so.preload, referenced libraries, hashes, process evidence, and timeline context before changing files."}
```

Supported JSONL fields:

- `rule_id`: stable detection identifier.
- `title`: human-readable finding title displayed in reports.
- `enabled`: set to `false` to disable a rule without deleting it.
- `severity`: `critical`, `high`, `medium`, `low`, or `informational`.
- `confidence`: analyst confidence level, such as `high`, `medium`, or `low`.
- `os`: target OS family, such as `macos`, `linux`, `unix`, or `all`.
- `artifact`: artifact category displayed in generated findings.
- `scope`: collected output path glob to search, such as `*/ASEP/*`.
- `pattern`: extended grep pattern applied to matching `stdout.log` files.
- `mitre_attack`: array or string of MITRE ATT&CK tactics/techniques.
- `tags`: array or string of analyst/search tags.
- `why_it_matters`: report-ready rationale.
- `false_positive_notes`: triage guidance for expected benign cases.
- `recommended_next_steps`: analyst action guidance.

Birtha applies the `os` field per host before writing findings. It reads the host OS from `Results/<run>/<host>/_preflight/profile.txt` when preflight is available, falling back to `SystemInfo/uname_a/stdout.log` when that module was collected. For example, a rule with `"os":"macos"` will not generate findings against a Linux/Raspberry Pi host whose profile reports `uname=Linux ...`.

OS matching behavior:

- `all` or an empty `os` value runs against every host.
- `macos` runs only against Darwin/macOS hosts.
- `linux` runs only against Linux hosts.
- `unix` runs against Linux, macOS, and other recognized Unix-like hosts.
- If Birtha cannot determine a host OS, it keeps legacy behavior and allows the rule to run rather than hiding potentially important evidence.

Keep preflight enabled for the most accurate report results. Using `--no-preflight` is still supported, but OS-aware rule filtering then depends on whether `Modules/SystemInfo/uname_a.sh` was collected.

### Enabling And Disabling Rules

Use the `enabled` field to turn JSONL detections on or off without deleting them.

Enabled rule:

```json
{"rule_id":"NETWORK_ESTABLISHED","title":"Established network connection observed","enabled":true,"severity":"medium","scope":"*/Network/*","pattern":"ESTABLISHED"}
```

Disabled rule:

```json
{"rule_id":"NETWORK_ESTABLISHED","title":"Established network connection observed","enabled":false,"severity":"medium","scope":"*/Network/*","pattern":"ESTABLISHED"}
```

Behavior:

- `enabled: true`: the rule runs and can generate prioritized findings.
- `enabled: false`: the rule is skipped and does not generate prioritized findings.
- Missing `enabled` field: Birtha treats the rule as enabled by default.

This is useful when a detection is too noisy for a specific environment but you want to preserve the rule content, history, and review context.

Example workflow:

```bash
./birtha-analyze.sh rules-check ./Rules/default.jsonl
./birtha-analyze.sh findings ./Results/<timestamp> ./Rules/default.jsonl
./birtha-analyze.sh html-report ./Results/<timestamp> --finding-limit 100
```

Birtha prefers `jq` when parsing JSONL rules. If `jq` is not installed, Birtha uses a fallback parser for the simple scalar and array fields above.

Validate rule files:

```bash
./birtha-analyze.sh rules-check
./birtha-analyze.sh rules-check ./Rules/default.jsonl
./birtha-analyze.sh rules-check ./Rules/macos_persistence.jsonl
./birtha-analyze.sh rules-check ./Rules/default.rules
```

Default rules currently detect categories such as:

- macOS persistence and suspicious LOLBins.
- macOS temporary persistence paths.
- SSH authorized key artifacts.
- Established network connections.
- Deleted open files.
- UID 0 and unusual account indicators.
- `/etc/ld.so.preload` and Linux preload abuse.
- Writable systemd/service paths.
- Unexpected Linux capabilities.
- PAM backdoor indicators.
- Recent package activity.
- Container artifacts.
- Unsigned macOS code and Gatekeeper/XProtect/MRT signals.
- macOS login items.

Reports rank findings in this order:

```text
critical
high
medium
low
informational
```

HTML `Prioritized Findings` cards can be collapsed and expanded. When collapsed, the severity, rule/title, and MITRE TA value remain visible.

Each HTML finding embeds the full triggering evidence file in a scrollable window. Birtha automatically scrolls that evidence window to the matched line and highlights the alert-triggering text while leaving the full raw log viewable by scrolling.

## Suppression Database

Prioritized finding suppressions are stored in:

```text
Rules/finding_suppressions.jsonl
```

Each line is one JSON object. Suppressions are applied when `findings`, `rules`, `report`, `markdown-report`, or `html-report` regenerate findings. Suppressed matches are written to `Results/<run>/suppressed_findings.jsonl` for auditability.

Example suppression:

```json
{"id":"expected-codex-network","enabled":true,"rule_id":"NETWORK_ESTABLISHED","evidence_path_contains":"/Network/lsof_i_n_P/","matched_value_regex":"Codex.*:443","reason":"Expected local Codex traffic during testing.","owner":"arron","created_utc":"2026-05-15T00:00:00Z"}
```

Supported suppression fields:

- `id`: unique suppression identifier.
- `enabled`: set to `false` to keep a suppression entry without applying it.
- `finding_key`: exact finding key to suppress.
- `rule_id`: suppress all findings from a rule, or combine with narrower fields.
- `host`: suppress matches for a specific collected host folder.
- `evidence_path`: suppress one exact evidence file path.
- `evidence_path_contains`: suppress paths containing a substring such as `/Network/`.
- `matched_sha256`: suppress a specific matched value hash.
- `matched_value_regex`: suppress matched values that satisfy a regular expression.
- `reason`: human-readable justification. This is required by `suppression-check`.
- `owner` and `created_utc`: optional audit fields for team ownership and review.

Rule-level suppression example:

```json
{"id":"suppress-deleted-open-file","enabled":true,"rule_id":"DELETED_OPEN_FILE","reason":"Expected deleted open files on this image after package updates.","owner":"analyst","created_utc":"2026-05-15T00:00:00Z"}
```

Targeted suppression example:

```json
{"id":"expected-systemd-timer","enabled":true,"rule_id":"LINUX_WRITABLE_SYSTEMD","host":"root_172.16.8.7","evidence_path_contains":"/ASEP/systemctl_list_timers_all/","matched_value_regex":"systemd-tmpfiles-clean","reason":"Known-good OS maintenance timer on this host.","owner":"analyst","created_utc":"2026-05-15T00:00:00Z"}
```

Exact suppression workflow:

```bash
./birtha-analyze.sh findings ./Results/<timestamp>
./birtha-analyze.sh suppression-add ./Results/<timestamp> BIRTHA-000001 "Known-good management traffic"
./birtha-analyze.sh html-report ./Results/<timestamp>
```

Use a custom suppression DB:

```bash
BIRTHA_SUPPRESSIONS_DB=./Rules/customer_suppressions.jsonl ./birtha-analyze.sh html-report ./Results/<timestamp>
```

## Report Output

Markdown report:

```text
Results/<run>/birtha-executive-report.md
```

HTML report:

```text
Results/<run>/birtha-executive-report.html
```

### HTML Report - Stats

The Stats areas give analysts a fast read on collection health and finding volume before diving into evidence. They summarize module runs, host and module counts, failures, skipped modules, timeouts, severity distribution, and suppression impact. In the Suppression Summary, `Active Findings` counts unsuppressed findings in `findings.jsonl`, while `Suppressed` counts matched findings written to `suppressed_findings.jsonl`.

### HTML Report - Findings

The Findings area is the analyst work queue for the report. It shows active prioritized findings ranked by severity, with rule title, MITRE mapping, matched value, matched line, rationale, and the full triggering evidence file in a compact scrollable window with highlighted matched text. Findings can be collapsed individually or controlled together with the single Collapse All/Expand All button.

The HTML report includes:

- Executive header and run metadata.
- Run health cards.
- Severity distribution.
- Suppression summary. `Active Findings` counts unsuppressed findings in `findings.jsonl`; `Suppressed` counts matched findings written to `suppressed_findings.jsonl`.
- Case metadata.
- Prioritized findings ranked by severity.
- Scrollable evidence previews from collected log files.
- Collapsible finding cards.
- A single Collapse All/Expand All control for prioritized findings.
- Complete collection timeline from `run_manifest.tsv`.
- A Collapse/Expand control for the Collection Timeline section.
- Failed/timed-out module list.
- Normalized artifact counts.
- Evidence preservation guidance.

## Environment Variables

### `BIRTHA_MAX_JOBS`

Default maximum concurrent jobs.

```bash
BIRTHA_MAX_JOBS=12 ./birtha.sh ./HostLists/hosts.txt ./BirthaConfigs/Default_Modules.conf
```

### `BIRTHA_MODULE_TIMEOUT`

Default per-module timeout in seconds.

```bash
BIRTHA_MODULE_TIMEOUT=180 ./birtha.sh --profile forensic-deep root@hostname
```

### `BIRTHA_OPEN_REPORT`

Controls whether generated reports open automatically. Set to `false` to suppress opening.

```bash
BIRTHA_OPEN_REPORT=false ./birtha-analyze.sh html-report ./Results/<timestamp>
BIRTHA_OPEN_REPORT=false ./birtha.sh --post-report html --local-host --profile fast
```

### `BIRTHA_REPORT_FINDING_LIMIT`

Default number of prioritized findings shown in reports when no CLI finding limit is supplied.

```bash
BIRTHA_REPORT_FINDING_LIMIT=100 ./birtha-analyze.sh html-report ./Results/<timestamp>
```

### `BIRTHA_SUPPRESSIONS_DB`

Path to the JSONL suppression database.

```bash
BIRTHA_SUPPRESSIONS_DB=./Rules/team_suppressions.jsonl ./birtha-analyze.sh findings ./Results/<timestamp>
```

### `BIRTHA_RULES_FILE`

Default rules file used when no rules file is supplied. JSONL is preferred, but legacy TSV `.rules` files are supported.

```bash
BIRTHA_RULES_FILE=./Rules/macos_persistence.jsonl ./birtha-analyze.sh html-report ./Results/<timestamp>
BIRTHA_RULES_FILE=./Rules/linux_ssh_compromise.jsonl ./birtha-analyze.sh findings ./Results/<timestamp>
```

## Safety Model

Birtha defaults to collection-first behavior.

- System-changing modules are blocked unless `--allow-changes` is supplied.
- Remediation modules live under `RemediationModules/`.
- Per-module metadata marks whether a module modifies the system.
- `--dry-run` and `--validate` support review before execution.
- `--strict-host-keys`, `--known-hosts`, and `--identity-file` support stronger SSH controls.

## Exit Behavior

Birtha writes collection results even when some modules fail.

- Successful collection with no failed module runs exits normally.
- If module runs fail or time out, Birtha warns and exits with code `2`.
- When `--post-report` is used, Birtha still generates the report before returning the module failure warning.

## Suggested SOC Workflows

Fast initial triage:

```bash
./birtha.sh --profile fast --post-report html root@hostname
```

Mac compromise triage:

```bash
./birtha.sh --case MAC-INC-001 --operator analyst --profile macos-compromise --post-report html root@mac-host
```

Local macOS persistence review:

```bash
./birtha.sh --local-host --profile macos-persistence --post-report html --all-findings
```

Linux SSH compromise:

```bash
./birtha.sh --case SSH-INC-001 --operator analyst --profile linux-ssh-compromise --post-report report root@linux-host
```

Multiple hosts with strict SSH handling:

```bash
./birtha.sh --case CASE-2026-001 --operator analyst --ticket INC-1042 --strict-host-keys --known-hosts ./known_hosts --identity-file ./ssh_keys/ir_ed25519 --post-report html ./HostLists/hosts.txt ./BirthaConfigs/Triage_Forensic_Deep.conf
```

Resume and retry failures:

```bash
./birtha.sh --resume ./Results/CASE-2026-001/run_2026_05_14_180000-0600 --retry-failed --post-report html root@hostname ./BirthaConfigs/Triage_SSH_Compromise.conf
```

Create sealed evidence bundle:

```bash
./birtha-analyze.sh bundle ./Results/CASE-2026-001/run_2026_05_14_180000-0600
```
