#!/bin/bash
# BIRTHA_TYPE=analyze
# BIRTHA_OS=all
# BIRTHA_CATEGORY=analysis
# BIRTHA_REQUIRES=local-results
# BIRTHA_MODIFIES_SYSTEM=false
# BIRTHA_EXPECTED_RUNTIME=short
# BIRTHA_OUTPUT=text

set -u

REPORT_FINDING_LIMIT="${BIRTHA_REPORT_FINDING_LIMIT:-50}"
REPORT_ALL_FINDINGS=false
DEFAULT_RULES_FILE="${BIRTHA_RULES_FILE:-Rules/default.jsonl}"

usage() {
    echo "Usage:"
    echo "  ./birtha-analyze.sh summarize <Results/run_dir>"
    echo "  ./birtha-analyze.sh failed-modules <Results/run_dir>"
    echo "  ./birtha-analyze.sh suspicious-persistence <Results/run_dir>"
    echo "  ./birtha-analyze.sh external-connections <Results/run_dir>"
    echo "  ./birtha-analyze.sh timeline <Results/run_dir>"
    echo "  ./birtha-analyze.sh normalize <Results/run_dir>"
    echo "  ./birtha-analyze.sh findings <Results/run_dir> [Rules/file.jsonl|Rules/file.rules]"
    echo "  ./birtha-analyze.sh suppressed-findings <Results/run_dir> [Rules/file.jsonl|Rules/file.rules]"
    echo "  ./birtha-analyze.sh suppression-list [Rules/finding_suppressions.jsonl]"
    echo "  ./birtha-analyze.sh suppression-check [Rules/finding_suppressions.jsonl]"
    echo "  ./birtha-analyze.sh suppression-add <Results/run_dir> <finding_id> [reason]"
    echo "  ./birtha-analyze.sh rules-check [Rules/file.jsonl|Rules/file.rules]"
    echo "  ./birtha-analyze.sh baseline <Results/run_dir>"
    echo "  ./birtha-analyze.sh diff <baseline_dir|baseline_file> <Results/run_dir>"
    echo "  ./birtha-analyze.sh rules <Results/run_dir> [Rules/file.jsonl|Rules/file.rules]"
    echo "  ./birtha-analyze.sh report <Results/run_dir>"
    echo "  ./birtha-analyze.sh markdown-report <Results/run_dir>"
    echo "  ./birtha-analyze.sh html-report <Results/run_dir>"
    echo "  ./birtha-analyze.sh html-report <Results/run_dir> --all-findings"
    echo "  ./birtha-analyze.sh html-report <Results/run_dir> --finding-limit 100"
    echo "  ./birtha-analyze.sh bundle <Results/run_dir>"
    exit 1
}

json_escape() {
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    value="${value//$'\n'/\\n}"
    value="${value//$'\r'/\\r}"
    value="${value//$'\t'/\\t}"
    printf '%s' "$value"
}

html_escape() {
    sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}

html_evidence_file() {
    local evidence_path="$1"
    local matched_line="$2"
    local matched_value="$3"

    awk -v target_line="$matched_line" -v matched_value="$matched_value" '
        function esc(s) {
            gsub(/&/, "\\&amp;", s)
            gsub(/</, "\\&lt;", s)
            gsub(/>/, "\\&gt;", s)
            return s
        }
        function emit_marked(raw, escaped, pos, before, match_text, after) {
            if (matched_value != "" && raw != matched_value) {
                pos = index(raw, matched_value)
                if (pos > 0) {
                    before = substr(raw, 1, pos - 1)
                    match_text = substr(raw, pos, length(matched_value))
                    after = substr(raw, pos + length(matched_value))
                    printf "%s<mark data-match=\"true\">%s</mark>%s", esc(before), esc(match_text), esc(after)
                    return
                }
            }
            printf "<mark data-match=\"true\">%s</mark>", escaped
        }
        {
            raw = $0
            escaped = esc(raw)
            is_match = (NR == target_line)
            if (is_match) {
                emit_marked(raw, escaped)
            } else {
                printf "%s", escaped
            }
            print ""
        }
        END {
            if (NR == 0) {
                print "[Evidence file is empty]"
            }
        }
    ' "$evidence_path"
}

sha256_text() {
    local value="$1"
    if command -v shasum >/dev/null 2>&1; then
        printf '%s' "$value" | shasum -a 256 | awk '{print $1}'
    elif command -v sha256sum >/dev/null 2>&1; then
        printf '%s' "$value" | sha256sum | awk '{print $1}'
    else
        printf '%s' "$value" | cksum | awk '{print $1}'
    fi
}

is_positive_integer() {
    [[ "$1" =~ ^[1-9][0-9]*$ ]]
}

validate_report_finding_options() {
    if [[ "$REPORT_ALL_FINDINGS" == true ]]; then
        return 0
    fi
    if ! is_positive_integer "$REPORT_FINDING_LIMIT"; then
        echo "!!! ERROR !!! -- --finding-limit must be a positive integer: $REPORT_FINDING_LIMIT" >&2
        exit 1
    fi
}

stdout_file_for_output_dir() {
    local output_dir="$1"

    if [[ -r "$output_dir/stdout.log" ]]; then
        printf '%s/stdout.log' "$output_dir"
    elif [[ -r "$output_dir/stdout.txt" ]]; then
        printf '%s/stdout.txt' "$output_dir"
    else
        printf '%s/stdout.log' "$output_dir"
    fi
}

sorted_findings_tsv() {
    local findings_file="$1"

    awk -F'"' '
        {
            sev=rule=title=path=val=why=mitre="";
            for (i=1; i<=NF; i++) {
                if ($i=="severity") sev=$(i+2)
                if ($i=="rule_id") rule=$(i+2)
                if ($i=="title") title=$(i+2)
                if ($i=="evidence_path") path=$(i+2)
                if ($i=="matched_value") val=$(i+2)
                if ($i=="why_it_matters") why=$(i+2)
                if ($i=="mitre_attack") mitre=$(i+2)
            }
            if (title == "") title = rule
            rank=5
            if (sev=="critical") rank=1
            else if (sev=="high") rank=2
            else if (sev=="medium") rank=3
            else if (sev=="low") rank=4
            else if (sev=="info" || sev=="informational") rank=5
            finding_line=""
            for (i=1; i<=NF; i++) {
                if ($i=="line") finding_line=$(i+1)
            }
            gsub(/^[^0-9]*/, "", finding_line)
            gsub(/[^0-9].*$/, "", finding_line)
            print rank "\t" NR "\t" sev "\t" rule "\t" title "\t" mitre "\t" val "\t" why "\t" path "\t" finding_line
        }
    ' "$findings_file" | sort -n -k1,1 -k2,2 | cut -f3-
}

limit_report_findings() {
    if [[ "$REPORT_ALL_FINDINGS" == true ]]; then
        cat
    else
        head -n "$REPORT_FINDING_LIMIT"
    fi
}

report_findings_note() {
    local active_findings="${1:-}"

    if [[ "$REPORT_ALL_FINDINGS" == true ]]; then
        if [[ -n "$active_findings" ]]; then
            printf 'All %s rule matches for analyst review' "$active_findings"
        else
            printf 'All rule matches for analyst review'
        fi
    elif [[ -n "$active_findings" && "$active_findings" -le "$REPORT_FINDING_LIMIT" ]]; then
        printf '%s rule matches for analyst review' "$active_findings"
    else
        printf 'Top %s rule matches for analyst review' "$REPORT_FINDING_LIMIT"
    fi
}

json_field() {
    local key="$1"
    awk -F'"' -v key="$key" '{
        for (i = 1; i <= NF; i++) {
            if ($i == key) {
                print $(i + 2)
                exit
            }
        }
    }'
}

jsonl_field_fallback() {
    local key="$1"
    awk -v key="$key" '
        {
            pattern = "\"" key "\"[[:space:]]*:[[:space:]]*"
            if (match($0, pattern "\"([^\"\\\\]|\\\\.)*\"")) {
                value = substr($0, RSTART, RLENGTH)
                sub("^" pattern "\"", "", value)
                sub("\"$", "", value)
                gsub(/\\"/, "\"", value)
                gsub(/\\\\/, "\\", value)
                print value
                exit
            }
            if (match($0, pattern "(true|false|null|[0-9]+)")) {
                value = substr($0, RSTART, RLENGTH)
                sub("^" pattern, "", value)
                print value
                exit
            }
            if (match($0, pattern "\\[[^]]*\\]")) {
                value = substr($0, RSTART, RLENGTH)
                sub("^" pattern "\\[", "", value)
                sub("\\]$", "", value)
                gsub(/[[:space:]]*\"[[:space:]]*/, "", value)
                gsub(/[[:space:]]*,[[:space:]]*/, ",", value)
                print value
                exit
            }
        }
    '
}

rules_file_default() {
    if [[ -r "$DEFAULT_RULES_FILE" ]]; then
        printf '%s' "$DEFAULT_RULES_FILE"
    else
        printf 'Rules/default.rules'
    fi
}

rules_file_format() {
    local rules_file="$1"

    case "$rules_file" in
        *.jsonl|*.json)
            printf 'jsonl'
            ;;
        *)
            printf 'tsv'
            ;;
    esac
}

rules_to_tsv() {
    local rules_file="$1"
    local format

    format="$(rules_file_format "$rules_file")"
    if [[ "$format" == "jsonl" ]]; then
        if command -v jq >/dev/null 2>&1; then
            jq -r '
                select((.enabled // true) == true) |
                [
                    (.rule_id // .id // ""),
                    (.title // .rule_id // .id // ""),
                    (.severity // "medium"),
                    (.pattern // .egrep_pattern // ""),
                    (.scope // .stdout_path_scope // "*"),
                    ((.mitre_attack // []) | if type == "array" then join(",") else tostring end),
                    (.confidence // "medium"),
                    (.why_it_matters // ""),
                    (.false_positive_notes // "Validate against known admin tooling and approved enterprise management software."),
                    (.recommended_next_steps // "Review the embedded evidence preview, correlate with process/network/log evidence, and preserve the evidence bundle before remediation."),
                    ((.tags // []) | if type == "array" then join(",") else tostring end),
                    ((.os // "all") | if type == "array" then join(",") else tostring end),
                    (.artifact // .scope // .stdout_path_scope // "*")
                ] | join("\u001c")
            ' "$rules_file"
        else
            while IFS= read -r line; do
                line="$(printf '%s' "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
                [[ -z "$line" || "$line" == \#* ]] && continue
                enabled="$(printf '%s\n' "$line" | jsonl_field_fallback enabled)"
                [[ "$enabled" == "false" ]] && continue
                rule_id="$(printf '%s\n' "$line" | jsonl_field_fallback rule_id)"
                [[ -z "$rule_id" ]] && rule_id="$(printf '%s\n' "$line" | jsonl_field_fallback id)"
                title="$(printf '%s\n' "$line" | jsonl_field_fallback title)"
                severity="$(printf '%s\n' "$line" | jsonl_field_fallback severity)"
                pattern="$(printf '%s\n' "$line" | jsonl_field_fallback pattern)"
                [[ -z "$pattern" ]] && pattern="$(printf '%s\n' "$line" | jsonl_field_fallback egrep_pattern)"
                scope="$(printf '%s\n' "$line" | jsonl_field_fallback scope)"
                [[ -z "$scope" ]] && scope="$(printf '%s\n' "$line" | jsonl_field_fallback stdout_path_scope)"
                mitre="$(printf '%s\n' "$line" | jsonl_field_fallback mitre_attack)"
                confidence="$(printf '%s\n' "$line" | jsonl_field_fallback confidence)"
                why="$(printf '%s\n' "$line" | jsonl_field_fallback why_it_matters)"
                false_positive="$(printf '%s\n' "$line" | jsonl_field_fallback false_positive_notes)"
                next_steps="$(printf '%s\n' "$line" | jsonl_field_fallback recommended_next_steps)"
                tags="$(printf '%s\n' "$line" | jsonl_field_fallback tags)"
                os="$(printf '%s\n' "$line" | jsonl_field_fallback os)"
                artifact="$(printf '%s\n' "$line" | jsonl_field_fallback artifact)"
                printf '%s\034%s\034%s\034%s\034%s\034%s\034%s\034%s\034%s\034%s\034%s\034%s\034%s\n' \
                    "$rule_id" "${title:-$rule_id}" "${severity:-medium}" "$pattern" "${scope:-*}" "$mitre" "${confidence:-medium}" "$why" \
                    "${false_positive:-Validate against known admin tooling and approved enterprise management software.}" \
                    "${next_steps:-Review the embedded evidence preview, correlate with process/network/log evidence, and preserve the evidence bundle before remediation.}" \
                    "$tags" "${os:-all}" "${artifact:-${scope:-*}}"
            done < "$rules_file"
        fi
    else
        while IFS=$'\t' read -r rule_id severity pattern scope; do
            [[ -z "$rule_id" || "$rule_id" == \#* ]] && continue
            printf '%s\034%s\034%s\034%s\034%s\034%s\034%s\034%s\034%s\034%s\034%s\034%s\034%s\n' \
                "$rule_id" "$rule_id" "${severity:-medium}" "$pattern" "${scope:-*}" "$(mitre_for_rule "$rule_id")" "medium" "$(why_for_rule "$rule_id")" \
                "Validate against known admin tooling and approved enterprise management software." \
                "Review the embedded evidence preview, correlate with process/network/log evidence, and preserve the evidence bundle before remediation." \
                "" "$(os_for_rule "$rule_id")" "${scope:-*}"
        done < "$rules_file"
    fi
}

validate_rules_file() {
    local rules_file="$1"
    local format

    [[ -r "$rules_file" ]] || { echo "!!! ERROR !!! -- Rules file not found: $rules_file" >&2; exit 1; }
    format="$(rules_file_format "$rules_file")"
    if [[ "$format" == "jsonl" ]] && command -v jq >/dev/null 2>&1; then
        if ! jq -s -e 'all(.[]; type == "object")' "$rules_file" >/dev/null 2>&1; then
            echo "!!! ERROR !!! -- JSONL rules file contains a non-object row: $rules_file" >&2
            exit 1
        fi
    fi
}

rules_check() {
    local rules_file="${1:-$(rules_file_default)}"
    local format
    local rows=0
    local failures=0
    local rule_id title severity pattern scope mitre confidence why false_positive next_steps tags os artifact

    validate_rules_file "$rules_file"
    format="$(rules_file_format "$rules_file")"
    while IFS=$'\034' read -r rule_id title severity pattern scope mitre confidence why false_positive next_steps tags os artifact; do
        rows=$((rows + 1))
        if [[ -z "$rule_id" || -z "$severity" || -z "$pattern" || -z "$scope" ]]; then
            echo "Invalid rule row $rows: rule_id, severity, pattern, and scope are required" >&2
            failures=1
        fi
    done < <(rules_to_tsv "$rules_file")

    if [[ "$failures" -ne 0 ]]; then
        return 1
    fi
    echo "Rules file looks valid: $rules_file"
    echo "Format: $format"
    echo "Enabled rules: $rows"
    if [[ "$format" == "jsonl" ]] && command -v jq >/dev/null 2>&1; then
        echo "Parser: jq"
    elif [[ "$format" == "jsonl" ]]; then
        echo "Parser: fallback"
    fi
}

suppression_file_default() {
    printf '%s' "${BIRTHA_SUPPRESSIONS_DB:-Rules/finding_suppressions.jsonl}"
}

ensure_suppression_file() {
    local suppressions_file="$1"
    mkdir -p "$(dirname "$suppressions_file")"
    [[ -f "$suppressions_file" ]] || : > "$suppressions_file"
}

suppression_key() {
    local rule_id="$1"
    local evidence_path="$2"
    local matched="$3"
    sha256_text "${rule_id}|${evidence_path}|${matched}"
}

suppression_matches() {
    local suppressions_file="$1"
    local key="$2"
    local host="$3"
    local rule_id="$4"
    local evidence_path="$5"
    local matched="$6"
    local matched_hash="$7"

    [[ -s "$suppressions_file" ]] || return 1
    awk -F'"' \
        -v key="$key" \
        -v host="$host" \
        -v rule_id="$rule_id" \
        -v evidence_path="$evidence_path" \
        -v matched="$matched" \
        -v matched_hash="$matched_hash" '
        function field(name,    i) {
            for (i = 1; i <= NF; i++) {
                if ($i == name) return $(i + 2)
            }
            return ""
        }
        function bool_field(name,    pattern) {
            pattern = "\"" name "\":[[:space:]]*false"
            return ($0 !~ pattern)
        }
        function regex_ok(regex, value) {
            if (regex == "") return 1
            return value ~ regex
        }
        function contains_ok(needle, value) {
            if (needle == "") return 1
            return index(value, needle) > 0
        }
        {
            if (!bool_field("enabled")) next
            s_key = field("finding_key")
            s_rule = field("rule_id")
            s_host = field("host")
            s_path = field("evidence_path")
            s_path_contains = field("evidence_path_contains")
            s_hash = field("matched_sha256")
            s_regex = field("matched_value_regex")

            if (s_key != "" && s_key == key) { found = 1; exit }
            if (s_rule != "" && s_rule != rule_id) next
            if (s_host != "" && s_host != host) next
            if (s_path != "" && s_path != evidence_path) next
            if (!contains_ok(s_path_contains, evidence_path)) next
            if (s_hash != "" && s_hash != matched_hash) next
            if (!regex_ok(s_regex, matched)) next
            if (s_rule != "" || s_host != "" || s_path != "" || s_path_contains != "" || s_hash != "" || s_regex != "") {
                found = 1
                exit
            }
        }
        END { exit found ? 0 : 1 }
    ' "$suppressions_file"
}

open_html_report() {
    local html_file="$1"

    if [[ "${BIRTHA_OPEN_REPORT:-true}" == "false" ]]; then
        return 0
    fi

    if command -v open >/dev/null 2>&1; then
        open "$html_file" >/dev/null 2>&1 &
        echo "Opened report: $html_file"
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$html_file" >/dev/null 2>&1 &
        echo "Opened report: $html_file"
    else
        echo "Report opener not found. Open manually: $html_file"
    fi
}

severity_score() {
    case "$1" in
        critical) printf '100' ;;
        high) printf '80' ;;
        medium) printf '50' ;;
        low) printf '25' ;;
        info|informational) printf '10' ;;
        *) printf '30' ;;
    esac
}

os_for_rule() {
    case "$1" in
        MAC_*|MACOS_*|LAUNCHD_*|BTM_*|TCC_*|QUARANTINE_*|GATEKEEPER_*|LOGIN_ITEM*|LAUNCHSERVICES_*|SYSTEM_EXTENSION|UNSIGNED_PERSISTENCE_EXECUTABLE)
            printf 'macos'
            ;;
        LINUX_*|SSH_*|PAM_*|UID_GID_*|LD_PRELOAD*|SYSTEMD_*|FILE_CAPABILITY|DELETED_RUNNING_FILE|PACKAGE_ACTIVITY|CONTAINER_*)
            printf 'linux'
            ;;
        *)
            printf 'all'
            ;;
    esac
}

os_family_from_text() {
    local value="$1"
    value="$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]')"

    case "$value" in
        *darwin*|*macos*|*mac\ os*|*osx*) printf 'macos' ;;
        *linux*) printf 'linux' ;;
        *freebsd*|*openbsd*|*netbsd*|*dragonfly*|*sunos*|*aix*) printf 'unix' ;;
        *) printf 'unknown' ;;
    esac
}

host_os_family() {
    local run_dir="$1"
    local host_dir="$2"
    local profile_file="$run_dir/$host_dir/_preflight/profile.txt"
    local uname_file
    local uname_text=""

    if [[ -r "$profile_file" ]]; then
        uname_text="$(awk -F= '/^uname=/ {sub(/^uname=/, ""); print; exit}' "$profile_file")"
    fi

    if [[ -z "$uname_text" ]]; then
        uname_file="$(stdout_file_for_output_dir "$run_dir/$host_dir/SystemInfo/uname_a")"
        if [[ -r "$uname_file" ]]; then
            uname_text="$(sed -n '1p' "$uname_file")"
        fi
    fi

    os_family_from_text "$uname_text"
}

rule_os_matches_host() {
    local rule_os="$1"
    local host_os="$2"
    local os_token

    rule_os="$(printf '%s' "${rule_os:-all}" | tr '[:upper:]' '[:lower:]' | tr ';|' ',,')"
    rule_os="${rule_os//\"/}"
    rule_os="${rule_os//\'/}"
    rule_os="${rule_os//[/}"
    rule_os="${rule_os//]/}"
    rule_os="${rule_os// /}"
    host_os="${host_os:-unknown}"

    if [[ -z "$rule_os" || "$rule_os" == "all" || "$rule_os" == "any" ]]; then
        return 0
    fi

    # If OS evidence is missing, keep legacy behavior rather than hiding findings.
    if [[ "$host_os" == "unknown" ]]; then
        return 0
    fi

    IFS=',' read -ra os_tokens <<< "$rule_os"
    for os_token in "${os_tokens[@]}"; do
        case "$os_token" in
            all|any)
                return 0
                ;;
            unix)
                [[ "$host_os" == "linux" || "$host_os" == "macos" || "$host_os" == "unix" ]] && return 0
                ;;
            mac|osx|darwin)
                [[ "$host_os" == "macos" ]] && return 0
                ;;
            "$host_os")
                return 0
                ;;
        esac
    done

    return 1
}

mitre_for_rule() {
    case "$1" in
        *PERSIST*|*LAUNCH*|*LOGIN*|*SYSTEMD*|*CRON*) printf 'TA0003' ;;
        *SSH*|*AUTH*|*LOGIN*) printf 'TA0001,TA0003,TA0006' ;;
        *NETWORK*|*CONNECTION*) printf 'TA0011' ;;
        *DELETED*|*LD_PRELOAD*|*CAPABILIT*) printf 'TA0005' ;;
        *TCC*|*PRIVACY*|*SUDO*|*UID0*) printf 'TA0004' ;;
        *PACKAGE*|*BROWSER*|*PROFILE*) printf 'TA0002,TA0003' ;;
        *) printf 'TA0002' ;;
    esac
}

why_for_rule() {
    case "$1" in
        *PERSIST*|*LAUNCH*) printf 'Potential persistence mechanism or suspicious autostart configuration.' ;;
        *SSH*) printf 'SSH authentication or authorized key evidence that may indicate access or persistence.' ;;
        *NETWORK*|*CONNECTION*) printf 'Network socket evidence that may indicate command-and-control, lateral movement, or exposed services.' ;;
        *DELETED*) printf 'A deleted-but-running file can indicate evasive malware or a replaced executable still resident in memory.' ;;
        *LD_PRELOAD*) printf 'LD_PRELOAD abuse can intercept process execution and is common in userland rootkits.' ;;
        *TCC*|*PRIVACY*) printf 'Privacy permission grants can expose screen, filesystem, microphone, or accessibility access on macOS.' ;;
        *CAPABILIT*) printf 'Unexpected Linux capabilities can grant privilege-like behavior without setuid bits.' ;;
        *UID0*) printf 'Nonstandard UID 0 users are high-risk privilege persistence.' ;;
        *) printf 'Rule matched content that should be reviewed during live incident response.' ;;
    esac
}

normalize_artifact() {
    local run_dir="$1"
    local output_dir="$run_dir/normalized"
    local manifest="$run_dir/run_manifest.tsv"

    mkdir -p "$output_dir"
    : > "$output_dir/processes.jsonl"
    : > "$output_dir/network_connections.jsonl"
    : > "$output_dir/persistence_items.jsonl"
    : > "$output_dir/users.jsonl"
    : > "$output_dir/ssh_keys.jsonl"
    : > "$output_dir/browser_extensions.jsonl"
    : > "$output_dir/tcc_grants.jsonl"
    : > "$output_dir/launchd_items.jsonl"
    : > "$output_dir/packages.jsonl"
    : > "$output_dir/containers.jsonl"
    : > "$output_dir/systemd_items.jsonl"
    : > "$output_dir/file_integrity.jsonl"

    awk -F '\t' '
        NR == 1 {
            for (i = 1; i <= NF; i++) col[$i] = i
            next
        }
        {
            print $(col["host"]) "\t" $(col["module"]) "\t" $(col["output_dir"])
        }
    ' "$manifest" | while IFS=$'\t' read -r host module output_path; do
        stdout_file="$(stdout_file_for_output_dir "$output_path")"
        [[ -r "$stdout_file" ]] || continue
        case "$module" in
            *RunningProcesses*|*ps_*|*pstree*)
                awk -v host="$host" -v module="$module" '
                    NF { gsub(/"/, "\\\""); print "{\"host\":\"" host "\",\"module\":\"" module "\",\"raw\":\"" $0 "\"}" }
                ' "$stdout_file" >> "$output_dir/processes.jsonl"
                ;;
            *Network/*|*NetworkInfo/*)
                awk -v host="$host" -v module="$module" '
                    NF { gsub(/"/, "\\\""); print "{\"host\":\"" host "\",\"module\":\"" module "\",\"raw\":\"" $0 "\"}" }
                ' "$stdout_file" >> "$output_dir/network_connections.jsonl"
                ;;
            *ASEP/*|*Launch*|*systemd*|*crontab*|*startup*|*login_items*)
                awk -v host="$host" -v module="$module" '
                    NF { gsub(/"/, "\\\""); print "{\"host\":\"" host "\",\"module\":\"" module "\",\"raw\":\"" $0 "\"}" }
                ' "$stdout_file" >> "$output_dir/persistence_items.jsonl"
                case "$module" in
                    *Launch*|*launch*)
                        awk -v host="$host" -v module="$module" '
                            NF { gsub(/"/, "\\\""); print "{\"host\":\"" host "\",\"module\":\"" module "\",\"raw\":\"" $0 "\"}" }
                        ' "$stdout_file" >> "$output_dir/launchd_items.jsonl"
                        ;;
                    *systemd*)
                        awk -v host="$host" -v module="$module" '
                            NF { gsub(/"/, "\\\""); print "{\"host\":\"" host "\",\"module\":\"" module "\",\"raw\":\"" $0 "\"}" }
                        ' "$stdout_file" >> "$output_dir/systemd_items.jsonl"
                        ;;
                esac
                ;;
            *passwd*|*dscl*|*sudoers*|*UID0*)
                awk -v host="$host" -v module="$module" '
                    NF { gsub(/"/, "\\\""); print "{\"host\":\"" host "\",\"module\":\"" module "\",\"raw\":\"" $0 "\"}" }
                ' "$stdout_file" >> "$output_dir/users.jsonl"
                ;;
            *authorized_keys*|*SSHKEY*|*ssh_keys*)
                awk -v host="$host" -v module="$module" '
                    NF { gsub(/"/, "\\\""); print "{\"host\":\"" host "\",\"module\":\"" module "\",\"raw\":\"" $0 "\"}" }
                ' "$stdout_file" >> "$output_dir/ssh_keys.jsonl"
                ;;
            *Browser*|*Chrome*|*Safari*)
                awk -v host="$host" -v module="$module" '
                    NF { gsub(/"/, "\\\""); print "{\"host\":\"" host "\",\"module\":\"" module "\",\"raw\":\"" $0 "\"}" }
                ' "$stdout_file" >> "$output_dir/browser_extensions.jsonl"
                ;;
            *TCC*)
                awk -v host="$host" -v module="$module" '
                    NF { gsub(/"/, "\\\""); print "{\"host\":\"" host "\",\"module\":\"" module "\",\"raw\":\"" $0 "\"}" }
                ' "$stdout_file" >> "$output_dir/tcc_grants.jsonl"
                ;;
            *InstalledApplications*|*packages*|*dpkg*|*apt*|*rpm*)
                awk -v host="$host" -v module="$module" '
                    NF { gsub(/"/, "\\\""); print "{\"host\":\"" host "\",\"module\":\"" module "\",\"raw\":\"" $0 "\"}" }
                ' "$stdout_file" >> "$output_dir/packages.jsonl"
                ;;
            *Containers*)
                awk -v host="$host" -v module="$module" '
                    NF { gsub(/"/, "\\\""); print "{\"host\":\"" host "\",\"module\":\"" module "\",\"raw\":\"" $0 "\"}" }
                ' "$stdout_file" >> "$output_dir/containers.jsonl"
                ;;
            *capabilities*|*ld_so_preload*|*writable*|*deleted*)
                awk -v host="$host" -v module="$module" '
                    NF { gsub(/"/, "\\\""); print "{\"host\":\"" host "\",\"module\":\"" module "\",\"raw\":\"" $0 "\"}" }
                ' "$stdout_file" >> "$output_dir/file_integrity.jsonl"
                ;;
        esac
    done

    echo "Normalized artifacts written: $output_dir"
}

write_findings() {
    local run_dir="$1"
    local rules_file="${2:-$(rules_file_default)}"
    local findings_file="$run_dir/findings.jsonl"
    local suppressed_file="$run_dir/suppressed_findings.jsonl"
    local suppressions_file
    local rule_id title severity pattern scope mitre confidence why false_positive next_steps tags os artifact score
    local match_file line_number matched
    local host host_os key matched_hash
    local finding_number=0
    local suppressed_number=0

    validate_rules_file "$rules_file"

    suppressions_file="$(suppression_file_default)"
    ensure_suppression_file "$suppressions_file"
    : > "$findings_file"
    : > "$suppressed_file"
    while IFS=$'\034' read -r rule_id title severity pattern scope mitre confidence why false_positive next_steps tags os artifact; do
        [[ -z "$rule_id" || "$rule_id" == \#* ]] && continue
        [[ -z "$pattern" ]] && continue
        [[ -z "$scope" ]] && scope='*'
        [[ -z "$title" ]] && title="$rule_id"
        [[ -z "$mitre" ]] && mitre="$(mitre_for_rule "$rule_id")"
        [[ -z "$confidence" ]] && confidence="medium"
        [[ -z "$why" ]] && why="$(why_for_rule "$rule_id")"
        [[ -z "$false_positive" ]] && false_positive="Validate against known admin tooling and approved enterprise management software."
        [[ -z "$next_steps" ]] && next_steps="Review the embedded evidence preview, correlate with process/network/log evidence, and preserve the evidence bundle before remediation."
        [[ -z "$artifact" ]] && artifact="$scope"
        score="$(severity_score "$severity")"
        while IFS=: read -r match_file line_number matched; do
            [[ -n "$match_file" && -n "$line_number" ]] || continue
            host="$(printf '%s' "$match_file" | awk -F/ '{print $(NF-3)}')"
            host_os="$(host_os_family "$run_dir" "$host")"
            if ! rule_os_matches_host "$os" "$host_os"; then
                continue
            fi
            matched_hash="$(sha256_text "$matched")"
            key="$(suppression_key "$rule_id" "$match_file" "$matched")"
            if suppression_matches "$suppressions_file" "$key" "$host" "$rule_id" "$match_file" "$matched" "$matched_hash"; then
                suppressed_number=$((suppressed_number + 1))
                printf '{"finding_id":"SUPPRESSED-%06d","finding_key":"%s","host":"%s","severity":"%s","rule_id":"%s","title":"%s","evidence_path":"%s","line":%s,"matched_sha256":"%s","matched_value":"%s","suppression_db":"%s"}\n' \
                    "$suppressed_number" \
                    "$(json_escape "$key")" \
                    "$(json_escape "$host")" \
                    "$(json_escape "$severity")" \
                    "$(json_escape "$rule_id")" \
                    "$(json_escape "$title")" \
                    "$(json_escape "$match_file")" \
                    "$line_number" \
                    "$(json_escape "$matched_hash")" \
                    "$(json_escape "$matched")" \
                    "$(json_escape "$suppressions_file")" >> "$suppressed_file"
                continue
            fi
            finding_number=$((finding_number + 1))
            printf '{"finding_id":"BIRTHA-%06d","finding_key":"%s","host":"%s","host_os":"%s","severity":"%s","confidence":"%s","score":%s,"rule_id":"%s","title":"%s","artifact":"%s","evidence_path":"%s","line":%s,"matched_sha256":"%s","matched_value":"%s","why_it_matters":"%s","false_positive_notes":"%s","mitre_attack":"%s","recommended_next_steps":"%s","tags":"%s","os":"%s","rules_file":"%s"}\n' \
                "$finding_number" \
                "$(json_escape "$key")" \
                "$(json_escape "$host")" \
                "$(json_escape "$host_os")" \
                "$(json_escape "$severity")" \
                "$(json_escape "$confidence")" \
                "$score" \
                "$(json_escape "$rule_id")" \
                "$(json_escape "$title")" \
                "$(json_escape "$artifact")" \
                "$(json_escape "$match_file")" \
                "$line_number" \
                "$(json_escape "$matched_hash")" \
                "$(json_escape "$matched")" \
                "$(json_escape "$why")" \
                "$(json_escape "$false_positive")" \
                "$(json_escape "$mitre")" \
                "$(json_escape "$next_steps")" \
                "$(json_escape "$tags")" \
                "$(json_escape "$os")" \
                "$(json_escape "$rules_file")" >> "$findings_file"
        done < <(find "$run_dir" -type f \( -name stdout.log -o -name stdout.txt \) -path "$scope" -print0 | xargs -0 grep -EIn "$pattern" 2>/dev/null || true)
    done < <(rules_to_tsv "$rules_file")

    echo "Findings written: $findings_file"
}

write_baseline() {
    local run_dir="$1"
    local baseline_dir="$run_dir/baseline"
    mkdir -p "$baseline_dir"
    normalize_artifact "$run_dir" >/dev/null
    for artifact in "$run_dir"/normalized/*.jsonl; do
        [[ -f "$artifact" ]] || continue
        sort -u "$artifact" > "$baseline_dir/$(basename "$artifact")"
    done
    find "$baseline_dir" -type f -print0 | sort -z | xargs -0 shasum -a 256 > "$baseline_dir/baseline_manifest.sha256"
    echo "Baseline written: $baseline_dir"
}

diff_baseline() {
    local baseline_input="$1"
    local run_dir="$2"
    local current_dir="$run_dir/normalized"
    local baseline_dir
    local diff_dir="$run_dir/diff"
    local artifact
    local base_file
    local out_file

    if [[ -d "$baseline_input/baseline" ]]; then
        baseline_dir="$baseline_input/baseline"
    elif [[ -d "$baseline_input" ]]; then
        baseline_dir="$baseline_input"
    else
        echo "!!! ERROR !!! -- baseline path not found: $baseline_input" >&2
        exit 1
    fi

    normalize_artifact "$run_dir" >/dev/null
    mkdir -p "$diff_dir"
    for artifact in "$current_dir"/*.jsonl; do
        [[ -f "$artifact" ]] || continue
        base_file="$baseline_dir/$(basename "$artifact")"
        out_file="$diff_dir/new_$(basename "$artifact")"
        if [[ -r "$base_file" ]]; then
            comm -13 <(sort -u "$base_file") <(sort -u "$artifact") > "$out_file"
        else
            sort -u "$artifact" > "$out_file"
        fi
    done
    echo "Diff written: $diff_dir"
}

suppression_list() {
    local suppressions_file="${1:-$(suppression_file_default)}"
    ensure_suppression_file "$suppressions_file"
    if [[ ! -s "$suppressions_file" ]]; then
        echo "No suppressions found: $suppressions_file"
        return 0
    fi
    awk -F'"' '
        function field(name,    i) {
            for (i = 1; i <= NF; i++) if ($i == name) return $(i + 2)
            return ""
        }
        {
            print field("id") "\t" field("enabled") "\t" field("rule_id") "\t" field("host") "\t" field("evidence_path_contains") "\t" field("reason")
        }
    ' "$suppressions_file"
}

suppression_check() {
    local suppressions_file="${1:-$(suppression_file_default)}"
    local failures=0
    ensure_suppression_file "$suppressions_file"
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        if ! printf '%s\n' "$line" | awk -F'"' '
            function has(name,    i) {
                for (i = 1; i <= NF; i++) if ($i == name) return 1
                return 0
            }
            !has("id") || !has("reason") { exit 1 }
        '; then
            echo "Invalid suppression row: $line" >&2
            failures=1
        fi
    done < "$suppressions_file"
    if [ "$failures" -eq 0 ]; then
        echo "Suppression database looks valid: $suppressions_file"
    fi
    return "$failures"
}

suppression_add() {
    local run_dir="$1"
    local finding_id="$2"
    local reason="${3:-Approved known-good finding}"
    local suppressions_file
    local finding_line
    local id rule_id host evidence_path matched_sha matched_value key created_utc

    suppressions_file="$(suppression_file_default)"
    ensure_suppression_file "$suppressions_file"
    if [[ ! -r "$run_dir/findings.jsonl" ]]; then
        write_findings "$run_dir" >/dev/null
    fi
    finding_line="$(awk -F'"' -v id="$finding_id" '{
        for (i = 1; i <= NF; i++) {
            if ($i == "finding_id" && $(i + 2) == id) {
                print
                exit
            }
        }
    }' "$run_dir/findings.jsonl")"
    if [[ -z "$finding_line" ]]; then
        echo "!!! ERROR !!! -- finding_id not found: $finding_id" >&2
        exit 1
    fi

    key="$(printf '%s\n' "$finding_line" | json_field finding_key)"
    rule_id="$(printf '%s\n' "$finding_line" | json_field rule_id)"
    host="$(printf '%s\n' "$finding_line" | json_field host)"
    evidence_path="$(printf '%s\n' "$finding_line" | json_field evidence_path)"
    matched_sha="$(printf '%s\n' "$finding_line" | json_field matched_sha256)"
    matched_value="$(printf '%s\n' "$finding_line" | json_field matched_value)"
    if [[ -z "$key" ]]; then
        key="$(suppression_key "$rule_id" "$evidence_path" "$matched_value")"
    fi
    created_utc="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    id="suppress-${key:0:12}"
    printf '{"id":"%s","enabled":true,"finding_key":"%s","rule_id":"%s","host":"%s","evidence_path":"%s","matched_sha256":"%s","reason":"%s","created_utc":"%s"}\n' \
        "$(json_escape "$id")" \
        "$(json_escape "$key")" \
        "$(json_escape "$rule_id")" \
        "$(json_escape "$host")" \
        "$(json_escape "$evidence_path")" \
        "$(json_escape "$matched_sha")" \
        "$(json_escape "$reason")" \
        "$(json_escape "$created_utc")" >> "$suppressions_file"
    echo "Suppression added: $id"
    echo "Database: $suppressions_file"
}

markdown_report() {
    local run_dir="$1"
    local report_file="$run_dir/birtha-executive-report.md"
    local findings_file="$run_dir/findings.jsonl"
    local suppressed_file="$run_dir/suppressed_findings.jsonl"
    write_findings "$run_dir" >/dev/null
    normalize_artifact "$run_dir" >/dev/null

    {
        echo "# Birtha Executive Incident Response Report"
        echo
        echo "## Executive Summary"
        echo
        echo "Birtha collected live-response evidence and generated triage findings for analyst review. Findings are prioritized by severity and should be correlated with known administrative activity before containment or remediation."
        echo
        echo "## Case Metadata"
        echo
        if [[ -r "$run_dir/case_manifest.json" ]]; then
            echo '```json'
            cat "$run_dir/case_manifest.json"
            echo '```'
        else
            echo "No case manifest found."
        fi
        echo
        echo "## Run Summary"
        echo
        echo '```text'
        "$0" summarize "$run_dir"
        echo '```'
        echo
        echo "## Prioritized Findings"
        echo
        printf 'Active findings: %s\n' "$(wc -l < "$findings_file" | tr -d ' ')"
        if [[ -r "$suppressed_file" ]]; then
            printf 'Suppressed findings: %s\n' "$(wc -l < "$suppressed_file" | tr -d ' ')"
        fi
        printf 'Displayed findings: %s\n' "$(report_findings_note "$(wc -l < "$findings_file" | tr -d ' ')")"
        echo
        echo
        if [[ -s "$findings_file" ]]; then
            sorted_findings_tsv "$findings_file" | limit_report_findings | awk -F'\t' '
                {
                    sev=$1; rule=$2; title=$3; mitre=$4; val=$5; why=$6; path=$7; line=$8
                    print "- **" sev "** `" rule "` " title ": " val
                    if (mitre != "") print "  MITRE: `" mitre "`"
                    print "  Evidence: `" path "`"
                    if (line != "") print "  Matched line: `" line "`"
                    print "  Why: " why
                }
            '
        else
            echo "No rule findings generated."
        fi
        echo
        echo "## Failed Or Timed Out Modules"
        echo
        echo '```text'
        "$0" failed-modules "$run_dir"
        echo '```'
        echo
        echo "## Normalized Artifacts"
        echo
        find "$run_dir/normalized" -type f -name '*.jsonl' -print | sort | while IFS= read -r artifact; do
            printf -- '- `%s`: %s records\n' "$artifact" "$(wc -l < "$artifact" | tr -d ' ')"
        done
        echo
        echo "## Evidence Integrity"
        echo
        echo "Use \`./birtha-analyze.sh bundle $run_dir\` to create a tarball with SHA256 file manifest and optional GPG signature."
    } > "$report_file"
    echo "Markdown report written: $report_file"
}

html_report() {
    local run_dir="$1"
    local html_file="$run_dir/birtha-executive-report.html"
    local findings_file="$run_dir/findings.jsonl"
    local suppressed_file="$run_dir/suppressed_findings.jsonl"
    local generated_utc
    local metrics
    local module_runs hosts modules failures skipped timeouts
    local finding_metrics
    local total_findings critical_findings high_findings medium_findings low_findings info_findings suppressed_findings
    local findings_note

    write_findings "$run_dir" >/dev/null
    normalize_artifact "$run_dir" >/dev/null
    findings_note="$(report_findings_note "$(wc -l < "$findings_file" | tr -d ' ')")"
    generated_utc="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    metrics="$(awk -F '\t' '
        NR == 1 {
            for (i = 1; i <= NF; i++) col[$i] = i
            next
        }
        {
            rows++
            hosts[$col["host"]] = 1
            modules[$col["module"]] = 1
            exit_code = $(col["exit_code"]) + 0
            if (exit_code == 125) skipped++
            else if (exit_code != 0) failures++
            if (exit_code == 124) timeouts++
        }
        END {
            for (h in hosts) host_count++
            for (m in modules) module_count++
            printf "%s %s %s %s %s %s", rows + 0, host_count + 0, module_count + 0, failures + 0, skipped + 0, timeouts + 0
        }
    ' "$manifest")"
    read -r module_runs hosts modules failures skipped timeouts <<< "$metrics"
    finding_metrics="$(awk -F'"' '
        {
            severity = "info"
            for (i = 1; i <= NF; i++) {
                if ($i == "severity") {
                    severity = $(i + 2)
                }
            }
            total++
            if (severity == "critical") critical++
            else if (severity == "high") high++
            else if (severity == "medium") medium++
            else if (severity == "low") low++
            else if (severity == "info" || severity == "informational") info++
            else info++
        }
        END {
            printf "%s %s %s %s %s %s", total + 0, critical + 0, high + 0, medium + 0, low + 0, info + 0
        }
    ' "$findings_file")"
    read -r total_findings critical_findings high_findings medium_findings low_findings info_findings <<< "$finding_metrics"
    suppressed_findings=0
    if [[ -r "$suppressed_file" ]]; then
        suppressed_findings="$(wc -l < "$suppressed_file" | tr -d ' ')"
    fi

    {
        cat <<'EOF'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Birtha Executive Incident Response Report</title>
<style>
:root {
  color-scheme: light;
  --bg: #f3f6f9;
  --panel: #ffffff;
  --ink: #17202a;
  --muted: #5d6b7a;
  --line: #d9e0e7;
  --accent: #145c9e;
  --accent-2: #0f766e;
  --critical: #7f1d1d;
  --high: #b42318;
  --medium: #b54708;
  --low: #2563eb;
  --info: #475569;
  --shadow: 0 16px 40px rgba(15, 23, 42, 0.08);
  --soft: #f8fafc;
}
* { box-sizing: border-box; }
body {
  margin: 0;
  background: var(--bg);
  color: var(--ink);
  font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  line-height: 1.5;
}
.page { max-width: 1180px; margin: 0 auto; padding: 32px 24px 56px; }
.hero {
  background:
    radial-gradient(circle at 82% 18%, rgba(255,255,255,.2), transparent 24%),
    linear-gradient(135deg, #102033 0%, #145c9e 56%, #0f766e 100%);
  color: white;
  border-radius: 8px;
  padding: 34px 38px;
  box-shadow: var(--shadow);
}
.eyebrow { margin: 0 0 8px; color: #c8d9ea; font-size: 12px; font-weight: 700; letter-spacing: .08em; text-transform: uppercase; }
h1 { margin: 0; font-size: 34px; line-height: 1.12; letter-spacing: 0; }
.subtitle { max-width: 820px; margin: 14px 0 0; color: #e7eef7; font-size: 16px; }
.meta-row { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 22px; }
.pill { border: 1px solid rgba(255,255,255,.28); border-radius: 999px; padding: 6px 11px; color: #eef6ff; font-size: 12px; background: rgba(255,255,255,.1); }
.focus-grid { display: grid; grid-template-columns: minmax(0, 1.18fr) minmax(320px, .82fr); gap: 18px; margin-top: 24px; align-items: start; }
.focus-grid .section { margin-top: 0; }
.section { margin-top: 24px; background: var(--panel); border: 1px solid var(--line); border-radius: 8px; box-shadow: var(--shadow); overflow: hidden; }
.section-header { padding: 18px 22px; border-bottom: 1px solid var(--line); display: flex; align-items: baseline; justify-content: space-between; gap: 16px; }
.section-heading { min-width: 0; }
.section-heading h2 { margin-bottom: 3px; }
.section-actions { display: flex; align-items: center; justify-content: flex-end; gap: 8px; flex-wrap: wrap; }
h2 { margin: 0; font-size: 18px; letter-spacing: 0; }
.section-note { color: var(--muted); font-size: 13px; }
.cards { display: grid; grid-template-columns: repeat(6, minmax(0, 1fr)); gap: 14px; padding: 18px 22px 22px; }
.signal-cards { display: grid; grid-template-columns: repeat(6, minmax(0, 1fr)); gap: 14px; padding: 18px 22px 22px; }
.card { border: 1px solid var(--line); border-radius: 8px; padding: 15px; background: #fbfcfe; min-width: 0; }
.card .label { color: var(--muted); font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: .04em; }
.card .value { margin-top: 8px; font-size: 28px; line-height: 1; font-weight: 750; color: var(--ink); }
.signal-card { position: relative; overflow: hidden; }
.signal-card::before { content: ""; position: absolute; inset: 0 auto 0 0; width: 5px; background: var(--info); }
.signal-card.critical::before { background: var(--critical); }
.signal-card.high::before { background: var(--high); }
.signal-card.medium::before { background: var(--medium); }
.signal-card.low::before { background: var(--low); }
.signal-card.info::before { background: var(--info); }
.content { padding: 20px 22px 24px; }
pre { margin: 0; background: #0f172a; color: #e5edf7; border-radius: 8px; padding: 16px; overflow: auto; font-size: 12px; line-height: 1.45; }
code { background: #eef2f7; border: 1px solid #d9e0e7; border-radius: 5px; padding: 1px 5px; }
table { width: 100%; border-collapse: collapse; font-size: 13px; }
th, td { padding: 10px 12px; border-bottom: 1px solid var(--line); text-align: left; vertical-align: top; }
th { color: var(--muted); font-size: 11px; text-transform: uppercase; letter-spacing: .05em; background: #f8fafc; }
.finding { border: 1px solid var(--line); border-left-width: 5px; border-radius: 8px; padding: 14px 16px; margin-bottom: 12px; background: #fff; transition: transform .15s ease, box-shadow .15s ease; }
.finding:hover { transform: translateY(-1px); box-shadow: 0 10px 24px rgba(15, 23, 42, .08); }
.finding.critical { border-left-color: var(--critical); }
.finding.high { border-left-color: var(--high); }
.finding.medium { border-left-color: var(--medium); }
.finding.low { border-left-color: var(--low); }
.finding.info { border-left-color: var(--info); }
.finding-header { display: flex; align-items: flex-start; justify-content: space-between; gap: 12px; }
.finding-title { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; min-width: 0; }
.finding-toggle, .section-toggle, .findings-bulk-toggle { appearance: none; border: 1px solid var(--line); border-radius: 6px; background: #f8fafc; color: #17202a; cursor: pointer; font: inherit; font-size: 12px; font-weight: 750; line-height: 1; padding: 8px 10px; white-space: nowrap; }
.finding-toggle:hover, .section-toggle:hover, .findings-bulk-toggle:hover { background: #eef2f7; border-color: #cbd5e1; }
.finding-toggle:focus-visible, .section-toggle:focus-visible, .findings-bulk-toggle:focus-visible { outline: 3px solid rgba(20, 92, 158, .25); outline-offset: 2px; }
.finding.is-collapsed .finding-body { display: none; }
.finding.is-collapsed .finding-title { margin-bottom: 0; }
.section.is-collapsed > .content { display: none; }
.badge { color: white; border-radius: 999px; padding: 3px 9px; font-size: 11px; font-weight: 800; text-transform: uppercase; }
.badge.critical { background: var(--critical); }
.badge.high { background: var(--high); }
.badge.medium { background: var(--medium); }
.badge.low { background: var(--low); }
.badge.info { background: var(--info); }
.rule { font-weight: 750; }
.finding p { margin: 7px 0; color: #263241; }
.path { color: var(--muted); word-break: break-all; font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; font-size: 12px; }
.evidence-block { margin-top: 12px; border: 1px solid var(--line); border-radius: 8px; overflow: hidden; background: var(--soft); }
.evidence-path { padding: 9px 12px; border-bottom: 1px solid var(--line); color: var(--muted); font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; font-size: 12px; word-break: break-all; background: #f8fafc; }
.evidence-window { max-height: 360px; overflow: auto; background: #0f172a; color: #e5edf7; padding: 8px; font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; font-size: 12px; line-height: 1; white-space: pre; }
.evidence-window mark { background: #fde047; color: #111827; border-radius: 2px; padding: 0; }
.timeline { position: relative; padding: 4px 0 0 12px; }
.timeline::before { content: ""; position: absolute; top: 8px; bottom: 4px; left: 17px; width: 2px; background: #dbe4ef; }
.timeline-item { position: relative; padding: 0 0 18px 28px; }
.timeline-dot { position: absolute; left: 0; top: 5px; width: 12px; height: 12px; border-radius: 50%; background: var(--accent-2); border: 3px solid #e8f3f1; z-index: 1; }
.timeline-dot.fail { background: var(--high); border-color: #fde8e5; }
.timeline-dot.skip { background: var(--medium); border-color: #fff0dd; }
.timeline-time { color: var(--muted); font-size: 12px; font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; }
.timeline-title { margin-top: 3px; font-weight: 750; word-break: break-word; }
.timeline-meta { color: var(--muted); font-size: 12px; word-break: break-all; }
.empty { color: var(--muted); padding: 18px 0; }
.footer { color: var(--muted); text-align: center; font-size: 12px; margin-top: 26px; }
@media (max-width: 980px) { .focus-grid { grid-template-columns: 1fr; } .cards, .signal-cards { grid-template-columns: repeat(2, minmax(0, 1fr)); } .hero { padding: 28px 24px; } }
@media (max-width: 640px) { .section-header, .finding-header { align-items: stretch; flex-direction: column; } .section-actions { justify-content: flex-start; } .finding-toggle { align-self: flex-start; } }
@media print {
  body { background: white; }
  .page { max-width: none; padding: 0; }
  .hero, .section { box-shadow: none; break-inside: avoid; }
  .finding { break-inside: avoid; }
}
</style>
</head>
<body>
<main class="page">
EOF
        echo '<section class="hero">'
        echo '<p class="eyebrow">Birtha Live Incident Response</p>'
        echo '<h1>Timeline and Findings Focus</h1>'
        echo '<p class="subtitle">A findings-first incident response report that puts severity, evidence, and collection timeline in the analyst path before supporting artifacts.</p>'
        echo '<div class="meta-row">'
        printf '<span class="pill">Generated UTC: %s</span>\n' "$(json_escape "$generated_utc" | html_escape)"
        printf '<span class="pill">Run: %s</span>\n' "$(json_escape "$run_dir" | html_escape)"
        echo '</div></section>'

        echo '<section class="section"><div class="section-header"><h2>Run At A Glance</h2><span class="section-note">Execution health and collection scope</span></div><div class="cards">'
        printf '<div class="card"><div class="label">Module Runs</div><div class="value">%s</div></div>\n' "$module_runs"
        printf '<div class="card"><div class="label">Hosts</div><div class="value">%s</div></div>\n' "$hosts"
        printf '<div class="card"><div class="label">Modules</div><div class="value">%s</div></div>\n' "$modules"
        printf '<div class="card"><div class="label">Failures</div><div class="value">%s</div></div>\n' "$failures"
        printf '<div class="card"><div class="label">Skipped</div><div class="value">%s</div></div>\n' "$skipped"
        printf '<div class="card"><div class="label">Timeouts</div><div class="value">%s</div></div>\n' "$timeouts"
        echo '</div></section>'

        echo '<section class="section"><div class="section-header"><h2>Finding Signal</h2><span class="section-note">Severity distribution from generated findings</span></div><div class="signal-cards">'
        printf '<div class="card signal-card critical"><div class="label">Critical</div><div class="value">%s</div></div>\n' "$critical_findings"
        printf '<div class="card signal-card high"><div class="label">High</div><div class="value">%s</div></div>\n' "$high_findings"
        printf '<div class="card signal-card medium"><div class="label">Medium</div><div class="value">%s</div></div>\n' "$medium_findings"
        printf '<div class="card signal-card low"><div class="label">Low</div><div class="value">%s</div></div>\n' "$low_findings"
        printf '<div class="card signal-card info"><div class="label">Info</div><div class="value">%s</div></div>\n' "$info_findings"
        echo '</div></section>'

        echo '<section class="section"><div class="section-header"><h2>Suppression Summary</h2><span class="section-note">JSONL suppression database impact</span></div><div class="cards">'
        printf '<div class="card"><div class="label">Active Findings</div><div class="value">%s</div></div>\n' "$total_findings"
        printf '<div class="card"><div class="label">Suppressed</div><div class="value">%s</div></div>\n' "$suppressed_findings"
        printf '<div class="card"><div class="label">Database</div><div class="value" style="font-size:13px;line-height:1.3;word-break:break-all">%s</div></div>\n' "$(printf '%s' "$(suppression_file_default)" | html_escape)"
        echo '</div></section>'

        echo '<section class="section"><div class="section-header"><h2>Case Metadata</h2><span class="section-note">Chain-of-custody context</span></div><div class="content"><pre>'
        if [[ -r "$run_dir/case_manifest.json" ]]; then
            html_escape < "$run_dir/case_manifest.json"
        else
            echo 'No case manifest found.'
        fi
        echo '</pre></div></section>'

        echo '<div class="focus-grid">'
        printf '<section class="section" id="prioritized-findings"><div class="section-header"><div class="section-heading"><h2>Prioritized Findings</h2><span class="section-note">%s</span></div><div class="section-actions"><button type="button" class="findings-bulk-toggle" aria-expanded="true">Collapse All</button></div></div><div class="content">\n' "$(printf '%s' "$findings_note" | html_escape)"
        if [[ -s "$findings_file" ]]; then
            sorted_findings_tsv "$findings_file" | limit_report_findings | while IFS=$'\t' read -r sev rule title mitre val why evidence_path evidence_line; do
                sev_class="${sev:-info}"
                [[ "$sev_class" == "informational" ]] && sev_class="info"
                display_path="$evidence_path"
                case "$display_path" in
                    ./*) ;;
                    Results/*) display_path="./$display_path" ;;
                    */Results/*) display_path="./Results/${display_path#*/Results/}" ;;
                esac

                printf '<article class="finding %s">\n' "$(printf '%s' "$sev_class" | html_escape)"
                echo '<div class="finding-header">'
                printf '<div class="finding-title"><span class="badge %s">%s</span><span class="rule">%s</span><span class="section-note">%s</span></div>\n' \
                    "$(printf '%s' "$sev_class" | html_escape)" \
                    "$(printf '%s' "$sev_class" | html_escape)" \
                    "$(printf '%s' "$title" | html_escape)" \
                    "$(printf '%s' "$mitre" | html_escape)"
                echo '<button type="button" class="finding-toggle" aria-expanded="true">Collapse</button>'
                echo '</div>'
                echo '<div class="finding-body">'
                printf '<p><strong>Matched value:</strong> %s</p>\n' "$(printf '%s' "$val" | html_escape)"
                printf '<p><strong>Matched line:</strong> %s</p>\n' "$(printf '%s' "${evidence_line:-unknown}" | html_escape)"
                printf '<p><strong>Why it matters:</strong> %s</p>\n' "$(printf '%s' "$why" | html_escape)"
                echo '<div class="evidence-block">'
                printf '<div class="evidence-path">%s</div>\n' "$(printf '%s' "$display_path" | html_escape)"
                echo '<div class="evidence-window">'
                if [[ -r "$evidence_path" ]]; then
                    html_evidence_file "$evidence_path" "${evidence_line:-0}" "$val"
                else
                    printf 'Evidence file is not readable: %s\n' "$evidence_path" | html_escape
                fi
                echo '</div></div>'
                echo '</div>'
                echo '</article>'
            done
        else
            echo '<p class="empty">No findings were generated by the current rule set.</p>'
        fi
        echo '</div></section>'

        echo '<section class="section" id="collection-timeline"><div class="section-header"><div class="section-heading"><h2>Collection Timeline</h2><span class="section-note">Every module run recorded in run_manifest.tsv</span></div><div class="section-actions"><button type="button" class="section-toggle" aria-expanded="true" data-target-section="collection-timeline">Collapse</button></div></div><div class="content"><div class="timeline">'
        awk -F '\t' '
                NR == 1 {
                    for (i = 1; i <= NF; i++) col[$i] = i
                    next
                }
                function esc(s) {
                    gsub(/&/, "\\&amp;", s); gsub(/</, "\\&lt;", s); gsub(/>/, "\\&gt;", s); return s
                }
                {
                    timestamp = $(col["timestamp_utc"])
                    host = $(col["host"])
                    module = $(col["module"])
                    shell = $(col["module_shell"])
                    transport = $(col["transport"])
                    duration = $(col["duration_seconds"])
                    exit_code = $(col["exit_code"])
                    output_dir = $(col["output_dir"])
                    dot="ok"
                    label="exit " exit_code
                    if (exit_code == "125") { dot="skip"; label="skipped" }
                    else if (exit_code != "" && exit_code != "0") { dot="fail"; label="exit " exit_code }
                    if (duration == "") duration = "0"
                    print timestamp "\t" sprintf("%08d", NR) "\t<article class=\"timeline-item\"><span class=\"timeline-dot " dot "\"></span><div class=\"timeline-time\">" esc(timestamp) " · " esc(label) " · " esc(duration) "s</div><div class=\"timeline-title\">" esc(module) "</div><div class=\"timeline-meta\">" esc(host) " · " esc(shell) " · " esc(transport) "</div><div class=\"timeline-meta\">" esc(output_dir) "</div></article>"
                }
            ' "$manifest" | sort -k1,1 -k2,2n | cut -f3-
        echo '</div></div></section>'
        echo '</div>'

        echo '<section class="section"><div class="section-header"><h2>Failed Or Timed Out Modules</h2><span class="section-note">Collection gaps to review</span></div><div class="content"><pre>'
        "$0" failed-modules "$run_dir" | html_escape
        echo '</pre></div></section>'

        echo '<section class="section"><div class="section-header"><h2>Normalized Artifacts</h2><span class="section-note">Structured records produced for analysis and diffing</span></div><div class="content"><table><thead><tr><th>Artifact</th><th>Records</th></tr></thead><tbody>'
        find "$run_dir/normalized" -type f -name '*.jsonl' -print | sort | while IFS= read -r artifact; do
            printf '<tr><td class="path">%s</td><td>%s</td></tr>\n' "$(printf '%s' "$artifact" | html_escape)" "$(wc -l < "$artifact" | tr -d ' ')"
        done
        echo '</tbody></table></div></section>'

        echo '<section class="section"><div class="section-header"><h2>Evidence Integrity</h2><span class="section-note">Preservation guidance</span></div><div class="content">'
        printf '<p>Create a sealed evidence archive with <code>./birtha-analyze.sh bundle %s</code>. The bundle includes a SHA256 file manifest and optional GPG detached signature when signing is available.</p>\n' "$(printf '%s' "$run_dir" | html_escape)"
        echo '</div></section>'
        echo '<p class="footer">Generated by Birtha. Preserve raw artifacts before containment or remediation.</p>'
        cat <<'EOF'
</main>
<script>
function setFindingExpanded(finding, expanded) {
  var button = finding.querySelector('.finding-toggle');
  finding.classList.toggle('is-collapsed', !expanded);
  if (button) {
    button.setAttribute('aria-expanded', expanded ? 'true' : 'false');
    button.textContent = expanded ? 'Collapse' : 'Expand';
  }
}
function syncFindingsBulkToggle() {
  var bulkButton = document.querySelector('#prioritized-findings .findings-bulk-toggle');
  if (!bulkButton) {
    return;
  }
  var findings = Array.prototype.slice.call(document.querySelectorAll('#prioritized-findings .finding'));
  var allExpanded = findings.length > 0 && findings.every(function (finding) {
    return !finding.classList.contains('is-collapsed');
  });
  bulkButton.setAttribute('aria-expanded', allExpanded ? 'true' : 'false');
  bulkButton.textContent = allExpanded ? 'Collapse All' : 'Expand All';
}
document.querySelectorAll('.finding-toggle').forEach(function (button) {
  button.addEventListener('click', function () {
    var finding = button.closest('.finding');
    if (finding) {
      setFindingExpanded(finding, finding.classList.contains('is-collapsed'));
      syncFindingsBulkToggle();
    }
  });
});
document.querySelectorAll('.findings-bulk-toggle').forEach(function (button) {
  button.addEventListener('click', function () {
    var expanded = button.getAttribute('aria-expanded') !== 'true';
    document.querySelectorAll('#prioritized-findings .finding').forEach(function (finding) {
      setFindingExpanded(finding, expanded);
    });
    syncFindingsBulkToggle();
  });
});
syncFindingsBulkToggle();
document.querySelectorAll('.section-toggle').forEach(function (button) {
  button.addEventListener('click', function () {
    var target = document.getElementById(button.getAttribute('data-target-section'));
    if (!target) {
      return;
    }
    var expanded = button.getAttribute('aria-expanded') === 'true';
    target.classList.toggle('is-collapsed', expanded);
    button.setAttribute('aria-expanded', expanded ? 'false' : 'true');
    button.textContent = expanded ? 'Expand' : 'Collapse';
  });
});
document.querySelectorAll('.evidence-window').forEach(function (windowEl) {
  var match = windowEl.querySelector('mark[data-match="true"]');
  if (match) {
    windowEl.scrollTop = Math.max(0, match.offsetTop - windowEl.offsetTop - Math.floor(windowEl.clientHeight / 3));
  }
});
</script>
</body>
</html>
EOF
    } > "$html_file"
    echo "HTML report written: $html_file"
    open_html_report "$html_file"
}

command_name="${1:-}"
run_dir="${2:-}"
shift $(( $# >= 2 ? 2 : $# ))
POSITIONAL_ARGS=()

while [ "$#" -gt 0 ]; do
    case "$1" in
        --all-findings|--all-prioritized-findings)
            REPORT_ALL_FINDINGS=true
            shift
            ;;
        --finding-limit|--prioritized-findings-limit)
            shift
            REPORT_FINDING_LIMIT="${1:-}"
            [[ -n "$REPORT_FINDING_LIMIT" ]] || { echo "!!! ERROR !!! -- --finding-limit requires a value" >&2; exit 1; }
            shift
            ;;
        --finding-limit=*|--prioritized-findings-limit=*)
            REPORT_FINDING_LIMIT="${1#*=}"
            shift
            ;;
        --)
            shift
            while [ "$#" -gt 0 ]; do
                POSITIONAL_ARGS+=("$1")
                shift
            done
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

third_arg="${POSITIONAL_ARGS[0]:-}"
fourth_arg="${POSITIONAL_ARGS[1]:-}"
validate_report_finding_options

if [[ "$command_name" == "rules-check" ]]; then
    rules_check "${run_dir:-$(rules_file_default)}"
    exit $?
fi

if [[ "$command_name" == "suppression-list" ]]; then
    suppression_list "${run_dir:-$(suppression_file_default)}"
    exit $?
fi

if [[ "$command_name" == "suppression-check" ]]; then
    suppression_check "${run_dir:-$(suppression_file_default)}"
    exit $?
fi

if [[ -z "$command_name" || -z "$run_dir" ]]; then
    usage
fi

if [[ "$command_name" == "diff" ]]; then
    if [[ -z "$third_arg" ]]; then
        usage
    fi
    diff_baseline "$run_dir" "$third_arg"
    exit 0
fi

if [[ "$command_name" == "suppression-add" ]]; then
    if [[ -z "$third_arg" ]]; then
        usage
    fi
    suppression_add "$run_dir" "$third_arg" "${fourth_arg:-Approved known-good finding}"
    exit $?
fi

manifest="$run_dir/run_manifest.tsv"
if [[ ! -r "$manifest" ]]; then
    echo "!!! ERROR !!! -- Manifest not found or unreadable: $manifest" >&2
    exit 1
fi

manifest_columns_awk='
    NR == 1 {
        for (i = 1; i <= NF; i++) col[$i] = i
        next
    }
'

case "$command_name" in
    summarize)
        awk -F '\t' "$manifest_columns_awk"'
            {
                rows++
                hosts[$col["host"]] = 1
                modules[$col["module"]] = 1
                shell[$col["module_shell"]]++
                transport[$col["transport"]]++
                modifies = $(col["modifies_system"])
                duration = $(col["duration_seconds"]) + 0
                exit_code = $(col["exit_code"]) + 0
                if (modifies == "true") modifying_runs++
                if (exit_code == 125) {
                    skipped++
                } else if (exit_code != 0) {
                    failures++
                    failed_by_code[exit_code]++
                }
                if (exit_code == 124) timeouts++
                if (rows == 1 || duration > max_duration) {
                    max_duration = duration
                    slowest = $0
                }
            }
            END {
                for (h in hosts) host_count++
                for (m in modules) module_count++
                print "Birtha Run Summary"
                print "------------------"
                print "Manifest: " FILENAME
                print "Module runs: " rows + 0
                print "Hosts: " host_count + 0
                print "Unique modules: " module_count + 0
                print "Failures: " failures + 0
                print "Skipped: " skipped + 0
                print "Timeouts: " timeouts + 0
                print "System-changing runs: " modifying_runs + 0
                print ""
                print "Transport:"
                for (t in transport) print "  " t ": " transport[t]
                print ""
                print "Shells:"
                for (s in shell) print "  " s ": " shell[s]
                if (rows > 0) {
                    print ""
                    print "Slowest run seconds: " max_duration + 0
                    print "Slowest run row: " slowest
                }
                if (failures > 0) {
                    print ""
                    print "Failures by exit code:"
                    for (code in failed_by_code) print "  " code ": " failed_by_code[code]
                }
            }
        ' "$manifest"
        ;;
    failed-modules)
        awk -F '\t' "$manifest_columns_awk"'
            BEGIN { print "host\tmodule\texit_code\tstderr" }
            {
                exit_code = $(col["exit_code"]) + 0
                if (exit_code != 0 && exit_code != 125) {
                    print $(col["host"]), $(col["module"]), exit_code, $(col["output_dir"]) "/stderr.txt"
                }
            }
        ' OFS='\t' "$manifest"
        ;;
    suspicious-persistence)
        find "$run_dir" -type f \( -name stdout.log -o -name stdout.txt \) \( -path '*/ASEP/*' -o -path '*/Audit/*' \) -print0 |
            xargs -0 grep -Ein 'curl|wget|osascript|python|perl|ruby|bash -c|/tmp|/var/tmp|/dev/shm|nc |ncat|socat|base64|chmod \+x|LaunchAgent|LaunchDaemon|systemd|LD_PRELOAD' 2>/dev/null || true
        ;;
    external-connections)
        find "$run_dir" -type f \( -name stdout.log -o -name stdout.txt \) \( -path '*/Network/*' -o -path '*/NetworkInfo/*' -o -path '*/RunningProcesses/lsof*' \) -print0 |
            xargs -0 grep -Ein 'ESTABLISHED|LISTEN|->[0-9]|[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+' 2>/dev/null || true
        ;;
    timeline)
        find "$run_dir" -name meta.txt -print0 |
            xargs -0 awk -F= '
                FILENAME != last_file {
                    if (last_file != "") print start, end, exit_code, module, host, last_file
                    host=module=start=end=exit_code=""
                    last_file=FILENAME
                }
                $1=="host"{host=$2}
                $1=="module"{module=$2}
                $1=="start_utc"{start=$2}
                $1=="end_utc"{end=$2}
                $1=="exit_code"{exit_code=$2}
                END {
                    if (last_file != "") print start, end, exit_code, module, host, last_file
                }
            ' | sort
        ;;
    normalize)
        normalize_artifact "$run_dir"
        ;;
    findings)
        write_findings "$run_dir" "$third_arg"
        ;;
    baseline)
        write_baseline "$run_dir"
        ;;
    rules)
        write_findings "$run_dir" "$third_arg" >/dev/null
        awk -F'"' '{for(i=1;i<=NF;i++){if($i=="severity") sev=$(i+2); if($i=="rule_id") rule=$(i+2); if($i=="evidence_path") path=$(i+2); if($i=="line") line=$(i+1); if($i=="matched_value") val=$(i+2)}} {print "[" sev "] " rule " " path " " val}' "$run_dir/findings.jsonl"
        ;;
    suppressed-findings)
        write_findings "$run_dir" "$third_arg" >/dev/null
        if [[ -s "$run_dir/suppressed_findings.jsonl" ]]; then
            cat "$run_dir/suppressed_findings.jsonl"
        else
            echo "No findings suppressed."
        fi
        ;;
    report|markdown-report)
        markdown_report "$run_dir"
        html_report "$run_dir" >/dev/null
        ;;
    html-report)
        html_report "$run_dir"
        ;;
    bundle)
        base="$(basename "$run_dir")"
        parent="$(dirname "$run_dir")"
        bundle="$parent/${base}-birtha-evidence.tar.gz"
        checksum="$bundle.sha256"
        manifest_out="$parent/${base}-birtha-evidence-manifest.sha256"
        manifest_inside="$run_dir/birtha-evidence-manifest.sha256"
        (cd "$run_dir" && find . -type f ! -name birtha-evidence-manifest.sha256 -print0 | sort -z | xargs -0 shasum -a 256) > "$manifest_inside"
        cp "$manifest_inside" "$manifest_out"
        tar -czf "$bundle" -C "$parent" "$base"
        shasum -a 256 "$bundle" > "$checksum"
        if command -v gpg >/dev/null 2>&1; then
            if gpg --batch --yes --armor --detach-sign "$bundle" >/dev/null 2>&1; then
                echo "Bundle signature: $bundle.asc"
            else
                echo "Bundle signature: skipped (gpg found, but signing failed)"
            fi
        else
            echo "Bundle signature: skipped (gpg not installed)"
        fi
        echo "Bundle written: $bundle"
        echo "Bundle checksum: $checksum"
        echo "File manifest: $manifest_out"
        ;;
    *)
        usage
        ;;
esac
