#!/bin/bash
#
# description:
#       This Script will perform Live IR and Threat Hunting on local or remote hosts using ssh keypair authentication.    
#
# usage:
#       Modules can be chosen in the "./Modules.conf" file. Simply comment '#' out lines you don't want to run. 
#       example: $ ./birtha.sh <root@HostName>
#       example: $ ./birtha.sh <root@IPaddr>
#       ** Host lists should contain one 'User@Hostname' per line.)
#       example: $ ./birtha.sh </path/to/hostlist.txt>   
#       example: $ ./birtha.sh </path/to/hostlist.txt>  [./birthaConfigs/Modules.conf]
#       example: $ ./birtha.sh localhost ./birthaConfigs/Network_Modules.conf
#       example: $ ./birtha.sh --dry-run ./HostLists/hosts.txt ./BirthaConfigs/MacOS_Modules.conf
#       example: $ ./birtha.sh --max-jobs 8 ./HostLists/hosts.txt
#       example: $ ./birtha.sh --allow-changes <root@HostName> ./BirthaConfigs/system_setup_config/disable_sshd_welcome_message_Ubuntu.conf
#       example: $ ./birtha.sh --validate ./BirthaConfigs/MacOS_Modules.conf
#       example: $ ./birtha.sh --local ./BirthaConfigs/MacOS_Modules.conf
#       example: $ ./birtha.sh --local-host --profile macos-compromise
#       example: $ ./birtha.sh --post-report html ./HostLists/hosts.txt ./BirthaConfigs/Default_Modules.conf
#       example: $ ./birtha.sh --list-modules --os macos --category persistence
#
# about: 
#	    The Birtha project: https://github.com/ArronJablonowski/birtha 
# 	    Author: Arron Jablonowski  	
#       Last Updated: 2024.8.28 
#

#########################################
############ Script Settings ############

multiHostNumber=2 # Setting to trigger multi hosts per module, all at the same time. 
multiHostMax=100 # Don't exceed this number of hosts at a time 
sshDelaySingleHost=0.5 # Slow things down a bit. ( 0.5 sec ) - Don't DoS yourself with too many ssh connections at once. 
sshDelayMultiHost=0.4 #
DEFAULT_CONFIG="./BirthaConfigs/Default_Modules.conf"
MAX_JOBS="${BIRTHA_MAX_JOBS:-8}"
MODULE_TIMEOUT="${BIRTHA_MODULE_TIMEOUT:-60}"
ORIGINAL_ARGS="$*"
DRY_RUN=false
ALLOW_CHANGES=false
VALIDATE_ONLY=false
LOCAL_MODE=false
LIST_MODULES=false
LIST_FILTER_OS=""
LIST_FILTER_CATEGORY=""
PROFILE=""
CASE_ID=""
OPERATOR=""
TICKET=""
NOTES=""
STRICT_HOST_KEYS=false
KNOWN_HOSTS_FILE=""
IDENTITY_FILE=""
RESUME_RUN=""
RETRY_FAILED=false
RUN_PREFLIGHT=true
POST_REPORT=""
REPORT_ALL_FINDINGS=false
REPORT_FINDING_LIMIT=""

###############################################
############ Advanced SSH Settings ############

### Set SSH Options here. Recommended to only add to what is listed below. 
### For strict incident cases, pre-populate Results/<timestamp>/known_hosts and change accept-new to yes.

###############################################
# @ll w@rr@n7y 15 nu11 & v01d # 

# Get the current time and format it into a proper directory name to hold the script's results 
#timestamp=$(date|tr ' ' '_' |tr ':' '.') #replace the spaces in date to "_" &  ':' to '.'  ## Old version 
timestamp=$(date +%Y_%m_%d_%H_%M_%S%z)
RESULTS_ROOT="./Results/$timestamp"
RUN_LABEL="run_$timestamp"

SSH_OPTIONS=(
    -oBatchMode=yes
    -oPasswordAuthentication=no
    -oConnectTimeout=10
    -oServerAliveInterval=15
    -oServerAliveCountMax=2
    -oStrictHostKeyChecking=accept-new
    -oUserKnownHostsFile="$RESULTS_ROOT/known_hosts"
)
# SSH_OPTIONS+=( -oPubkeyAcceptedAlgorithms=+ssh-rsa ) ## example: force algo ssh-rsa for older OpenWRT/dropbear versions ##

# ASCII ART 
echo_ascii1(){
clear 	
echo '' 
echo '                      by: Arron Jablonowski                       '
echo '         BASH INCIDENT RESPONSE & THREAT HUNT AUTOMATION          ' 
echo '      _                      _______                       _      '
echo '   _dMMMb._              .ad0000100000ba               _,dMMMb_   '
echo '  dP  ~YMMb             d001001010000010b            aMMP~  `Yb   '
echo '  V      ~"Mb          d00100000101001000b          dM"~      V   '
echo '           `Mb.       d0010000101010100010b       ,dMl            '
echo '            `YMb._   |000000000000000000000|   _,dMPl             '
echo '       __     `YMMM| OP~~"YOOOOOOOOOOOP"~~YO |MMMPl     __        '
echo '     ,dMMMb.     ~~~ OO     `YOOOOOP`     OO ~~~     ,dMMMb.      '
echo '  _,dP~  `YMba_      OOb      `OOO`      dOO      _aMMP   ~Yb._   '
echo ' <MMP      `~YMMa_   YOOo   @   V  @    oOOP   _adMP~       `YMM> '
echo '              `YMMMM\`OOOo     /O\     oOOO /MMMMP                '
echo '      ,aa.      `~YMMb OOOb._,dOOOb._,dOOO dMMP~        ,aa.      '
echo '    ,dMYYMba._          00101000100010100          _,adMYYMb.     '
echo '   ,MP    `YMMba._      01001000101000100       _,adMMP    `YM.   '
echo '   MP         ~YMMMba._ 00100111111010010  _,adMMMMP~       `YM   '
echo '   YMb           ~YMMMM\`00011^SSH^01010/MMMMP~            dMP    '
echo '    `Mb.           `YMMMb`OO00011100010,dMMMP            ,dM      '
echo '      `                    01000100100                    `       '
echo '         `Mb.         dMMMb` ~OO1OO~ ,dMMMb           `ab         '
echo '        YMb        /MMMMP             `YMMMb            dM        '
echo '       MP       _,adMMP~                 ~YMMba.         YMb      ' 
echo '       YM._   ,adMMP                       `YMMba._    ,MMP       '
echo '         adMYYMb/            ~~~~~~~~         ,dMYYMbYab`         '
echo '           `aa"               BIRTHA              `aa"            '
echo '                             ~~~~~~~~                             '
echo '' 
#sleep 2
} 

# Script Functions
trim_line() {
    local line="$1"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    printf '%s' "$line"
}

is_blank_or_comment() {
    local line
    line="$(trim_line "$1")"
    [[ -z "$line" || "$line" == \#* ]]
}

sanitize_path_part() {
    printf '%s' "$1" | tr '/:@[] ' '______' | tr -cd 'A-Za-z0-9._-'
}

configure_results_and_ssh() {
    local strict_value="accept-new"
    local known_hosts_path

    if [[ -n "$RESUME_RUN" ]]; then
        RESULTS_ROOT="${RESUME_RUN%/}"
    elif [[ -n "$CASE_ID" ]]; then
        RESULTS_ROOT="./Results/$(sanitize_path_part "$CASE_ID")/$RUN_LABEL"
    else
        RESULTS_ROOT="./Results/$timestamp"
    fi

    if [[ "$STRICT_HOST_KEYS" == true ]]; then
        strict_value="yes"
    fi

    known_hosts_path="${KNOWN_HOSTS_FILE:-$RESULTS_ROOT/known_hosts}"
    SSH_OPTIONS=(
        -oBatchMode=yes
        -oPasswordAuthentication=no
        -oConnectTimeout=10
        -oServerAliveInterval=15
        -oServerAliveCountMax=2
        -oStrictHostKeyChecking="$strict_value"
        -oUserKnownHostsFile="$known_hosts_path"
    )
    if [[ -n "$IDENTITY_FILE" ]]; then
        SSH_OPTIONS+=(-i "$IDENTITY_FILE")
    fi
}

sha256_file() {
    local file="$1"
    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$file" | awk '{print $1}'
    elif command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$file" | awk '{print $1}'
    else
        printf 'sha256_unavailable'
    fi
}

init_results() {
    mkdir -p "$RESULTS_ROOT"
    if [[ ! -f "$RESULTS_ROOT/run_manifest.tsv" ]]; then
        printf 'timestamp_utc\thost\tmodule\tmodule_shell\ttransport\tmodifies_system\tduration_seconds\texit_code\tstdout_sha256\tstderr_sha256\toutput_dir\n' > "$RESULTS_ROOT/run_manifest.tsv"
    fi
    [[ -f "$RESULTS_ROOT/run_manifest.jsonl" ]] || : > "$RESULTS_ROOT/run_manifest.jsonl"
}

write_case_manifest() {
    local config_file="$1"
    local git_commit="unknown"
    local local_host="unknown"
    local config_sha

    if [[ -n "$RESUME_RUN" && -f "$RESULTS_ROOT/case_manifest.json" ]]; then
        cat >> "$RESULTS_ROOT/resume_events.jsonl" <<EOF
{"resumed_utc":"$(date -u +%Y-%m-%dT%H:%M:%SZ)","operator":"$(json_escape "$OPERATOR")","ticket":"$(json_escape "$TICKET")","notes":"$(json_escape "$NOTES")","command_line":"$(json_escape "./birtha.sh $ORIGINAL_ARGS")"}
EOF
        return 0
    fi

    git_commit="$(git rev-parse --short HEAD 2>/dev/null || printf 'unknown')"
    local_host="$(hostname 2>/dev/null || printf 'unknown')"
    config_sha="$(sha256_file "$config_file")"

    cat > "$RESULTS_ROOT/case_manifest.json" <<EOF
{
  "case_id": "$(json_escape "$CASE_ID")",
  "run_label": "$(json_escape "$RUN_LABEL")",
  "operator": "$(json_escape "$OPERATOR")",
  "ticket": "$(json_escape "$TICKET")",
  "notes": "$(json_escape "$NOTES")",
  "started_utc": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "birtha_git_commit": "$(json_escape "$git_commit")",
  "collector_hostname": "$(json_escape "$local_host")",
  "config_file": "$(json_escape "$config_file")",
  "config_sha256": "$(json_escape "$config_sha")",
  "command_line": "$(json_escape "./birtha.sh $ORIGINAL_ARGS")",
  "results_root": "$(json_escape "$RESULTS_ROOT")"
}
EOF
}

is_positive_integer() {
    [[ "$1" =~ ^[1-9][0-9]*$ ]]
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

echo_config() {
    configlinecount=0
    configFile=$1
    echo ""
    echo "CONFIG FILE FOUND: $configFile"
    [[ "$DRY_RUN" == true ]] || sleep 2
    echo "LISTING MODULES:"
    while IFS= read -r line
	do	
        ((configlinecount++))
        if ! is_blank_or_comment "$line"; then
            echo " [ Line: $configlinecount ] - Module: $(trim_line "$line") " # verbose w/line count
        fi
	done < "$configFile"
    [[ "$DRY_RUN" == true ]] || sleep 5
}

check_config(){
    configFile=$1
    #Check if Config file exists  
    if [[ -z "$configFile" || ! -r "$configFile" ]]; then
        echo "!!! ERROR !!! -- Config File Not Found or Unreadable: $configFile" >&2
        exit 1
    fi
}

validate_module() {
    local module="$1"

    if [[ ! -f "$module" ]]; then
        echo " X !3rr0r! -- Script NOT Found: $module"
        return 1
    fi

    return 0
}

module_modifies_system() {
    local module="$1"

    if grep -Eq '^#[[:space:]]*BIRTHA_MODIFIES_SYSTEM=true[[:space:]]*$' "$module"; then
        return 0
    fi

    case "$module" in
        ./RemediationModules/system_config_scripts/*|RemediationModules/system_config_scripts/*|./RemediationModules/OS_Hardening/*|RemediationModules/OS_Hardening/*)
            return 0
            ;;
    esac

    return 1
}

module_has_modifies_metadata() {
    local module="$1"

    grep -Eq '^#[[:space:]]*BIRTHA_MODIFIES_SYSTEM=(true|false)[[:space:]]*$' "$module"
}

module_dependencies() {
    local module="$1"

    module_metadata_value "$module" "BIRTHA_DEPENDS" ""
}

profile_config() {
    case "$1" in
        fast)
            printf './BirthaConfigs/Triage_Network_Processes.conf'
            ;;
        standard)
            printf './BirthaConfigs/Default_Modules.conf'
            ;;
        macos-initial|macos-compromise)
            printf './BirthaConfigs/Triage_MacOS_Initial.conf'
            ;;
        macos-persistence)
            printf './BirthaConfigs/Triage_MacOS_Persistence.conf'
            ;;
        linux-ssh-compromise|ssh-compromise)
            printf './BirthaConfigs/Triage_SSH_Compromise.conf'
            ;;
        linux-compromise|unix-compromise)
            printf './BirthaConfigs/Triage_Linux_Unix_Compromise.conf'
            ;;
        cryptominer)
            printf './BirthaConfigs/Triage_CryptoMiner.conf'
            ;;
        forensic-deep)
            printf './BirthaConfigs/Triage_Forensic_Deep.conf'
            ;;
        *)
            return 1
            ;;
    esac
}

module_metadata_value() {
    local module="$1"
    local key="$2"
    local default_value="$3"
    local value

    value="$(awk -F= -v key="$key" '
        $0 ~ "^#[[:space:]]*" key "=" {
            sub("^#[[:space:]]*" key "=", "", $0)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
            print $0
            exit
        }
    ' "$module")"

    if [[ -n "$value" ]]; then
        printf '%s' "$value"
    else
        printf '%s' "$default_value"
    fi
}

should_run_module() {
    local module="$1"

    if module_modifies_system "$module" && [[ "$ALLOW_CHANGES" != true ]]; then
        echo " [SKIP] modifying module requires --allow-changes: $module"
        return 1
    fi

    return 0
}

module_shell() {
    local module="$1"

    case "$module" in
        *.zsh)
            printf 'zsh'
            ;;
        *)
            printf 'bash'
            ;;
    esac
}

module_default_os() {
    local module="$1"

    case "$module" in
        *.zsh|*MacOS*|*/Browsers/*|*/ASEP/*Launch*|*/ASEP/*sfltool*|*/Logs/log_show_*|*/SystemInfo/dscl_*|*/Audit/csrutil_*|*/Audit/fdesetup_*|*/Audit/profiles_*|*/Audit/spctl_*|*/Audit/security_*)
            printf 'macos'
            ;;
        */Network/*|*/NetworkInfo/*|*/RunningProcesses/*|*/DiskUsage/*|*/Logs/*|*/SystemInfo/*|*/Audit/*)
            printf 'unix'
            ;;
        *)
            printf 'all'
            ;;
    esac
}

module_default_category() {
    local module="$1"

    case "$module" in
        */ASEP/*)
            printf 'persistence'
            ;;
        */Network/*|*/NetworkInfo/*|*/Firewall/*)
            printf 'network'
            ;;
        */RunningProcesses/*)
            printf 'process'
            ;;
        */Logs/*|*/Auditd/*)
            printf 'logs'
            ;;
        */Browsers/*)
            printf 'browser'
            ;;
        */DiskUsage/*)
            printf 'filesystem'
            ;;
        */InstalledApplications/*)
            printf 'software'
            ;;
        */Audit/*)
            printf 'audit'
            ;;
        */OS_Hardening/*|*/system_config_scripts/*)
            printf 'modify'
            ;;
        */SystemInfo/*)
            printf 'system'
            ;;
        *)
            printf 'general'
            ;;
    esac
}

module_type() {
    local module="$1"

    if module_modifies_system "$module"; then
        printf 'modify'
    else
        module_metadata_value "$module" "BIRTHA_TYPE" "collect"
    fi
}

validate_module_syntax() {
    local module="$1"
    local shell_name

    shell_name="$(module_shell "$module")"

    if ! command -v "$shell_name" >/dev/null 2>&1; then
        echo " X !3rr0r! -- Required shell not found for $module: $shell_name" >&2
        return 1
    fi

    if ! "$shell_name" -n "$module" >/dev/null 2>&1; then
        echo " X !3rr0r! -- Syntax check failed with $shell_name -n: $module" >&2
        "$shell_name" -n "$module" >&2
        return 1
    fi

    return 0
}

validate_host() {
    local host="$1"

    if [[ "$host" =~ [[:space:]] ]]; then
        echo " X !3rr0r! -- Invalid host entry contains whitespace: $host" >&2
        return 1
    fi

    return 0
}

validate_max_jobs() {
    if ! is_positive_integer "$MAX_JOBS"; then
        echo "!!! ERROR !!! -- max jobs must be a positive integer: $MAX_JOBS" >&2
        exit 1
    fi
}

validate_timeout() {
    if ! is_positive_integer "$MODULE_TIMEOUT"; then
        echo "!!! ERROR !!! -- timeout must be a positive integer: $MODULE_TIMEOUT" >&2
        exit 1
    fi
}

normalize_post_report_format() {
    local format
    format="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"

    case "$format" in
        html|html-report)
            printf 'html'
            ;;
        markdown|markdown-report|md)
            printf 'markdown'
            ;;
        report|executive|executive-report)
            printf 'report'
            ;;
        *)
            return 1
            ;;
    esac
}

validate_post_report_format() {
    local normalized

    [[ -n "$POST_REPORT" ]] || return 0
    if ! normalized="$(normalize_post_report_format "$POST_REPORT")"; then
        echo "!!! ERROR !!! -- unsupported --post-report format: $POST_REPORT" >&2
        echo "Supported formats: html, markdown, report" >&2
        exit 1
    fi
    POST_REPORT="$normalized"
}

validate_report_finding_options() {
    [[ -z "$REPORT_FINDING_LIMIT" ]] && return 0
    if ! is_positive_integer "$REPORT_FINDING_LIMIT"; then
        echo "!!! ERROR !!! -- --finding-limit must be a positive integer: $REPORT_FINDING_LIMIT" >&2
        exit 1
    fi
}

open_generated_report_file() {
    local report_file="$1"

    [[ "${BIRTHA_OPEN_REPORT:-true}" == "false" ]] && return 0
    [[ -f "$report_file" ]] || return 1

    if command -v open >/dev/null 2>&1; then
        open "$report_file" >/dev/null 2>&1 &
        echo "Opened report: $report_file"
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$report_file" >/dev/null 2>&1 &
        echo "Opened report: $report_file"
    else
        echo "Report ready: $report_file"
        echo "No supported opener found. Open it manually with your preferred application."
    fi
}

run_post_report() {
    local format="$1"
    local analyzer="./birtha-analyze.sh"
    local report_file
    local analyzer_args=()

    [[ -n "$format" ]] || return 0
    if [[ ! -r "$analyzer" ]]; then
        echo "!!! ERROR !!! -- cannot find readable analyzer script: $analyzer" >&2
        return 1
    fi

    if [[ "$REPORT_ALL_FINDINGS" == true ]]; then
        analyzer_args+=(--all-findings)
    elif [[ -n "$REPORT_FINDING_LIMIT" ]]; then
        analyzer_args+=(--finding-limit "$REPORT_FINDING_LIMIT")
    fi

    echo ">> Post-collection report: $format"
    case "$format" in
        html)
            bash "$analyzer" html-report "$RESULTS_ROOT" "${analyzer_args[@]}"
            ;;
        markdown)
            bash "$analyzer" markdown-report "$RESULTS_ROOT" "${analyzer_args[@]}"
            report_file="$RESULTS_ROOT/birtha-executive-report.md"
            open_generated_report_file "$report_file"
            ;;
        report)
            bash "$analyzer" report "$RESULTS_ROOT" "${analyzer_args[@]}"
            ;;
        *)
            echo "!!! ERROR !!! -- unsupported post report format: $format" >&2
            return 1
            ;;
    esac
}

wait_with_timeout() {
    local pid="$1"
    local timeout_seconds="$2"
    local start_epoch
    local now_epoch
    local exit_code

    start_epoch="$(date +%s)"
    while kill -0 "$pid" 2>/dev/null; do
        now_epoch="$(date +%s)"
        if [ $((now_epoch - start_epoch)) -ge "$timeout_seconds" ]; then
            kill -- "-$pid" 2>/dev/null
            kill "$pid" 2>/dev/null
            sleep 1
            kill -9 -- "-$pid" 2>/dev/null
            kill -9 "$pid" 2>/dev/null
            wait "$pid" 2>/dev/null
            return 124
        fi
        sleep 0.2
    done

    wait "$pid"
    exit_code=$?
    return "$exit_code"
}

wait_for_slot() {
    local running_jobs

    while true; do
        running_jobs="$(jobs -pr | wc -l | tr -d ' ')"
        if [ "$running_jobs" -lt "$MAX_JOBS" ]; then
            break
        fi
        sleep 0.2
    done
}

enqueue_module() {
    local userAtHost="$1"
    local script_module="$2"
    local delay="$3"

    if [[ "$DRY_RUN" == true ]]; then
        run_module "$userAtHost" "$script_module"
        return 0
    fi

    wait_for_slot
    run_module "$userAtHost" "$script_module" &
    sleep "$delay"
}

count_active_hosts() {
    local hostlist="$1"
    local count=0
    local host

    while IFS= read -r host; do
        if ! is_blank_or_comment "$host"; then
            ((count++))
        fi
    done < "$hostlist"

    printf '%s' "$count"
}

validate_host_input() {
    local target="$1"
    local hostcount
    local host
    local failures=0

    if [[ -z "$target" ]]; then
        echo " [OK] No host or host list supplied for validation."
        return 0
    fi

    if [[ -f "$target" ]]; then
        if [[ ! -r "$target" ]]; then
            echo " X !3rr0r! -- Host list not readable: $target" >&2
            return 1
        fi

        hostcount="$(count_active_hosts "$target")"
        if [ "$hostcount" -eq 0 ]; then
            echo " X !3rr0r! -- Host list has no active hosts: $target" >&2
            return 1
        fi

        echo " [OK] Host list readable: $target ($hostcount active hosts)"
        if [ "$hostcount" -gt "$multiHostMax" ]; then
            echo " X !3rr0r! -- Host count $hostcount exceeds multiHostMax $multiHostMax" >&2
            failures=1
        fi

        while IFS= read -r host; do
            host="$(trim_line "$host")"
            if ! is_blank_or_comment "$host" && ! validate_host "$host"; then
                failures=1
            fi
        done < "$target"
    else
        if validate_host "$target"; then
            echo " [OK] Host entry looks usable: $target"
        else
            failures=1
        fi
    fi

    return "$failures"
}

validate_config_modules() {
    local configFile="$1"
    local line_number=0
    local module
    local active_modules=0
    local modifying_modules=0
    local failures=0
    local required_key

    echo "VALIDATING CONFIG: $configFile"
    while IFS= read -r module; do
        ((line_number++))
        module="$(trim_line "$module")"
        if is_blank_or_comment "$module"; then
            continue
        fi

        ((active_modules++))
        if ! validate_module "$module"; then
            echo "   Source: $configFile:$line_number" >&2
            failures=1
            continue
        fi

        if validate_module_syntax "$module"; then
            echo " [OK] $module ($(module_shell "$module") -n)"
        else
            echo "   Source: $configFile:$line_number" >&2
            failures=1
        fi

        for required_key in BIRTHA_TYPE BIRTHA_OS BIRTHA_CATEGORY BIRTHA_REQUIRES BIRTHA_MODIFIES_SYSTEM BIRTHA_EXPECTED_RUNTIME BIRTHA_OUTPUT BIRTHA_CONFIDENCE BIRTHA_NOISE_LEVEL BIRTHA_TRIAGE_PRIORITY BIRTHA_DEPENDS; do
            if ! grep -Eq "^#[[:space:]]*$required_key=" "$module"; then
                echo " X !3rr0r! -- Module lacks metadata $required_key: $module" >&2
                failures=1
            fi
        done

        if module_modifies_system "$module"; then
            ((modifying_modules++))
            if module_has_modifies_metadata "$module"; then
                echo " [OK] Modifying module is tagged: $module"
            else
                echo " X !3rr0r! -- Modifying module lacks BIRTHA_MODIFIES_SYSTEM metadata: $module" >&2
                failures=1
            fi
        fi
    done < "$configFile"

    if [ "$active_modules" -eq 0 ]; then
        echo " X !3rr0r! -- Config has no active modules: $configFile" >&2
        failures=1
    fi

    echo "VALIDATION SUMMARY: active_modules=$active_modules modifying_modules=$modifying_modules"
    return "$failures"
}

run_validation() {
    local target="$1"
    local configFile="$2"
    local failures=0

    echo "      [ VALIDATE MODE: ENABLED - no SSH commands will run and no Results directory will be created ]"
    echo "      [ Config: $configFile ]"

    validate_host_input "$target" || failures=1
    validate_config_modules "$configFile" || failures=1

    if [ "$failures" -eq 0 ]; then
        echo ">> Validation complete. No problems found."
        return 0
    fi

    echo ">> Validation complete. Problems were found." >&2
    return 1
}

completed_module_success() {
    local host="$1"
    local module="$2"

    [[ -r "$RESULTS_ROOT/run_manifest.tsv" ]] || return 1
    awk -F '\t' -v host="$host" -v module="$module" '
        NR == 1 {
            for (i = 1; i <= NF; i++) col[$i] = i
            next
        }
        $(col["host"]) == host && $(col["module"]) == module && $(col["exit_code"]) == "0" {
            found = 1
        }
        END {
            exit found ? 0 : 1
        }
    ' "$RESULTS_ROOT/run_manifest.tsv"
}

completed_module_failed() {
    local host="$1"
    local module="$2"

    [[ -r "$RESULTS_ROOT/run_manifest.tsv" ]] || return 1
    awk -F '\t' -v host="$host" -v module="$module" '
        NR == 1 {
            for (i = 1; i <= NF; i++) col[$i] = i
            next
        }
        $(col["host"]) == host && $(col["module"]) == module && $(col["exit_code"]) != "0" {
            found = 1
        }
        END {
            exit found ? 0 : 1
        }
    ' "$RESULTS_ROOT/run_manifest.tsv"
}

should_run_for_resume() {
    local host="$1"
    local module="$2"

    if [[ -z "$RESUME_RUN" ]]; then
        return 0
    fi

    if [[ "$RETRY_FAILED" == true ]]; then
        if completed_module_failed "$host" "$module"; then
            return 0
        fi
        echo " [SKIP] retry-failed mode skipping non-failed module: $host $module"
        return 1
    fi

    if completed_module_success "$host" "$module"; then
        echo " [SKIP] resume found successful module: $host $module"
        return 1
    fi

    return 0
}

run_host_preflight() {
    local host="$1"
    local safe_host
    local preflight_dir
    local profile_file
    local deps_file
    local preflight_script
    local preflight_pid
    local preflight_rc

    [[ "$RUN_PREFLIGHT" == true ]] || return 0
    [[ "$DRY_RUN" == true ]] && return 0

    safe_host="$(sanitize_path_part "$host")"
    preflight_dir="$RESULTS_ROOT/$safe_host/_preflight"
    profile_file="$preflight_dir/profile.txt"
    deps_file="$preflight_dir/dependencies.txt"
    mkdir -p "$preflight_dir"

    preflight_script='
echo "preflight_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)"
echo "hostname=$(hostname 2>/dev/null)"
echo "whoami=$(whoami 2>/dev/null)"
echo "uname=$(uname -a 2>/dev/null)"
for cmd in bash zsh sh awk sed grep find getent lsof ps netstat ss sqlite3 log launchctl systemextensionsctl codesign osascript profiles spctl sfltool plutil eslogger docker podman crictl systemctl getcap stat journalctl ausearch rpm dpkg apt; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "cmd:$cmd=present:$(command -v "$cmd")"
    else
        echo "cmd:$cmd=missing"
    fi
done
'

    if [[ "$LOCAL_MODE" == true ]]; then
        sh -s > "$profile_file" 2> "$preflight_dir/stderr.txt" <<< "$preflight_script" &
    else
        ssh "${SSH_OPTIONS[@]}" "$host" "sh -s" > "$profile_file" 2> "$preflight_dir/stderr.txt" <<< "$preflight_script" &
    fi
    preflight_pid=$!
    wait_with_timeout "$preflight_pid" "$MODULE_TIMEOUT"
    preflight_rc=$?
    if [ "$preflight_rc" -eq 124 ]; then
        echo "BIRTHA_TIMEOUT: preflight exceeded ${MODULE_TIMEOUT}s and was terminated" >> "$preflight_dir/stderr.txt"
    fi
    echo "exit_code=$preflight_rc" > "$preflight_dir/meta.txt"

    awk -F= '/^cmd:/ {print $1 "=" $2}' "$profile_file" > "$deps_file" 2>/dev/null || true
}

dependencies_available() {
    local host="$1"
    local module="$2"
    local deps
    local dep
    local safe_host
    local deps_file
    local missing=0

    deps="$(module_dependencies "$module")"
    [[ -z "$deps" ]] && return 0

    deps="${deps//,/ }"
    safe_host="$(sanitize_path_part "$host")"
    deps_file="$RESULTS_ROOT/$safe_host/_preflight/dependencies.txt"

    if [[ ! -r "$deps_file" ]]; then
        echo " [WARN] dependency preflight missing for $host; running $module anyway"
        return 0
    fi

    for dep in $deps; do
        if ! grep -Eq "^cmd:${dep}=present" "$deps_file"; then
            echo " [SKIP] missing dependency on $host for $module: $dep"
            record_module_skip "$host" "$module" "missing_dependency" "$dep"
            missing=1
        fi
    done

    [ "$missing" -eq 0 ]
}

list_modules() {
    local module
    local os
    local category
    local type
    local requires
    local runtime
    local shell_name
    local modifies
    local confidence
    local noise
    local priority
    local depends

    printf 'type\tos\tcategory\trequires\truntime\tconfidence\tnoise\tpriority\tdepends\tshell\tmodifies_system\tmodule\n'
    while IFS= read -r module; do
        type="$(module_type "$module")"
        os="$(module_metadata_value "$module" "BIRTHA_OS" "$(module_default_os "$module")")"
        category="$(module_metadata_value "$module" "BIRTHA_CATEGORY" "$(module_default_category "$module")")"
        requires="$(module_metadata_value "$module" "BIRTHA_REQUIRES" "unknown")"
        runtime="$(module_metadata_value "$module" "BIRTHA_EXPECTED_RUNTIME" "unknown")"
        confidence="$(module_metadata_value "$module" "BIRTHA_CONFIDENCE" "medium")"
        noise="$(module_metadata_value "$module" "BIRTHA_NOISE_LEVEL" "medium")"
        priority="$(module_metadata_value "$module" "BIRTHA_TRIAGE_PRIORITY" "3")"
        depends="$(module_dependencies "$module")"
        shell_name="$(module_shell "$module")"
        modifies=false
        if module_modifies_system "$module"; then
            modifies=true
        fi

        if [[ -n "$LIST_FILTER_OS" && "$os" != "$LIST_FILTER_OS" && "$os" != "all" ]]; then
            continue
        fi
        if [[ -n "$LIST_FILTER_CATEGORY" && "$category" != "$LIST_FILTER_CATEGORY" ]]; then
            continue
        fi

        printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$type" "$os" "$category" "$requires" "$runtime" "$confidence" "$noise" "$priority" "$depends" "$shell_name" "$modifies" "$module"
    done < <(find Modules RemediationModules -type f \( -name '*.sh' -o -name '*.zsh' \) 2>/dev/null | sort)
}

run_module() {
    local userAtHost="$1"
    local script_module="$2"
    local script_fullname
    local script_module_dir
    local script_name
    local safe_host
    local output_dir
    local stdout_file
    local stderr_file
    local meta_file
    local start_utc
    local end_utc
    local exit_code
    local stdout_hash
    local stderr_hash
    local modifies_system
    local remote_shell
    local transport
    local start_epoch
    local end_epoch
    local duration_seconds
    local module_pid

    script_fullname="$(basename "$script_module")"
    script_module_dir="$(basename "$(dirname "$script_module")")"
    script_name="${script_fullname%.*}"
    safe_host="$(sanitize_path_part "$userAtHost")"
    remote_shell="$(module_shell "$script_module")"
    transport="ssh"
    if [[ "$LOCAL_MODE" == true ]]; then
        transport="local"
    fi
    modifies_system=false
    if module_modifies_system "$script_module"; then
        modifies_system=true
    fi
    output_dir="$RESULTS_ROOT/$safe_host/$script_module_dir/$script_name"
    stdout_file="$output_dir/stdout.log"
    stderr_file="$output_dir/stderr.txt"
    meta_file="$output_dir/meta.txt"

    if [[ "$DRY_RUN" == true ]]; then
        if [[ "$LOCAL_MODE" == true ]]; then
            echo " [DRY-RUN] local '$remote_shell -s' < $script_fullname"
        else
            echo " [DRY-RUN] ssh $userAtHost '$remote_shell -s' < $script_fullname"
        fi
        return 0
    fi

    if ! should_run_for_resume "$userAtHost" "$script_module"; then
        return 0
    fi
    if ! dependencies_available "$userAtHost" "$script_module"; then
        return 0
    fi

    mkdir -p "$output_dir"

    start_utc="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    {
        echo "host=$userAtHost"
        echo "module=$script_module"
        echo "module_shell=$remote_shell"
        echo "transport=$transport"
        echo "modifies_system=$modifies_system"
        echo "dependencies=$(module_dependencies "$script_module")"
        echo "confidence=$(module_metadata_value "$script_module" "BIRTHA_CONFIDENCE" "medium")"
        echo "noise_level=$(module_metadata_value "$script_module" "BIRTHA_NOISE_LEVEL" "medium")"
        echo "triage_priority=$(module_metadata_value "$script_module" "BIRTHA_TRIAGE_PRIORITY" "3")"
        echo "module_sha256=$(sha256_file "$script_module")"
        echo "start_utc=$start_utc"
        echo "timeout_seconds=$MODULE_TIMEOUT"
        echo "ssh_options=${SSH_OPTIONS[*]}"
    } > "$meta_file"

    start_epoch="$(date +%s)"
    if [[ "$LOCAL_MODE" == true ]]; then
        echo " ~ $ $remote_shell -s < $script_fullname"
        "$remote_shell" -s < "$script_module" > "$stdout_file" 2> "$stderr_file" &
    else
        echo " ~ $ ssh $userAtHost '$remote_shell -s' < $script_fullname"
        ssh "${SSH_OPTIONS[@]}" "$userAtHost" "$remote_shell -s" < "$script_module" > "$stdout_file" 2> "$stderr_file" &
    fi
    module_pid=$!
    wait_with_timeout "$module_pid" "$MODULE_TIMEOUT"
    exit_code=$?
    if [ "$exit_code" -eq 124 ]; then
        echo "BIRTHA_TIMEOUT: module exceeded ${MODULE_TIMEOUT}s and was terminated" >> "$stderr_file"
    fi

    end_epoch="$(date +%s)"
    duration_seconds=$((end_epoch - start_epoch))
    end_utc="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    stdout_hash="$(sha256_file "$stdout_file")"
    stderr_hash="$(sha256_file "$stderr_file")"

    {
        echo "end_utc=$end_utc"
        echo "duration_seconds=$duration_seconds"
        echo "exit_code=$exit_code"
        echo "stdout_sha256=$stdout_hash"
        echo "stderr_sha256=$stderr_hash"
    } >> "$meta_file"

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$end_utc" "$userAtHost" "$script_module" "$remote_shell" "$transport" "$modifies_system" "$duration_seconds" "$exit_code" "$stdout_hash" "$stderr_hash" "$output_dir" >> "$RESULTS_ROOT/run_manifest.tsv"
    printf '{"timestamp_utc":"%s","host":"%s","module":"%s","module_shell":"%s","transport":"%s","modifies_system":%s,"duration_seconds":%s,"exit_code":%s,"stdout_sha256":"%s","stderr_sha256":"%s","output_dir":"%s"}\n' \
        "$(json_escape "$end_utc")" \
        "$(json_escape "$userAtHost")" \
        "$(json_escape "$script_module")" \
        "$(json_escape "$remote_shell")" \
        "$(json_escape "$transport")" \
        "$modifies_system" \
        "$duration_seconds" \
        "$exit_code" \
        "$(json_escape "$stdout_hash")" \
        "$(json_escape "$stderr_hash")" \
        "$(json_escape "$output_dir")" >> "$RESULTS_ROOT/run_manifest.jsonl"

    return "$exit_code"
}

record_module_skip() {
    local userAtHost="$1"
    local script_module="$2"
    local reason="$3"
    local detail="$4"
    local script_fullname
    local script_module_dir
    local script_name
    local safe_host
    local output_dir
    local meta_file
    local remote_shell
    local transport
    local modifies_system=false
    local end_utc

    script_fullname="$(basename "$script_module")"
    script_module_dir="$(basename "$(dirname "$script_module")")"
    script_name="${script_fullname%.*}"
    safe_host="$(sanitize_path_part "$userAtHost")"
    remote_shell="$(module_shell "$script_module")"
    transport="ssh"
    [[ "$LOCAL_MODE" == true ]] && transport="local"
    module_modifies_system "$script_module" && modifies_system=true
    output_dir="$RESULTS_ROOT/$safe_host/$script_module_dir/$script_name"
    meta_file="$output_dir/meta.txt"
    end_utc="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

    mkdir -p "$output_dir"
    {
        echo "host=$userAtHost"
        echo "module=$script_module"
        echo "module_shell=$remote_shell"
        echo "transport=$transport"
        echo "modifies_system=$modifies_system"
        echo "status=skipped"
        echo "skip_reason=$reason"
        echo "skip_detail=$detail"
        echo "end_utc=$end_utc"
    } > "$meta_file"
    : > "$output_dir/stdout.log"
    printf '%s\n' "BIRTHA_SKIP: $reason $detail" > "$output_dir/stderr.txt"

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$end_utc" "$userAtHost" "$script_module" "$remote_shell" "$transport" "$modifies_system" "0" "125" "skipped" "skipped" "$output_dir" >> "$RESULTS_ROOT/run_manifest.tsv"
    printf '{"timestamp_utc":"%s","host":"%s","module":"%s","module_shell":"%s","transport":"%s","modifies_system":%s,"duration_seconds":0,"exit_code":125,"status":"skipped","skip_reason":"%s","skip_detail":"%s","output_dir":"%s"}\n' \
        "$(json_escape "$end_utc")" \
        "$(json_escape "$userAtHost")" \
        "$(json_escape "$script_module")" \
        "$(json_escape "$remote_shell")" \
        "$(json_escape "$transport")" \
        "$modifies_system" \
        "$(json_escape "$reason")" \
        "$(json_escape "$detail")" \
        "$(json_escape "$output_dir")" >> "$RESULTS_ROOT/run_manifest.jsonl"
}

count_failed_module_runs() {
    if [[ ! -r "$RESULTS_ROOT/run_manifest.tsv" ]]; then
        printf '0'
        return 0
    fi

    awk -F '\t' '
        NR == 1 {
            for (i = 1; i <= NF; i++) {
                if ($i == "exit_code") {
                    exit_col = i
                }
            }
            next
        }
        exit_col && $exit_col != "0" && $exit_col != "125" {
            failures++
        }
        END {
            print failures + 0
        }
    ' "$RESULTS_ROOT/run_manifest.tsv"
}

### Run ALL modules against ONE host at a time. ### 
Run_LiveIR() {   
    userAtHost=$1
    configFile=$2

    validate_host "$userAtHost" || return 1
    run_host_preflight "$userAtHost"
    echo_ascii1
    echo_config "$configFile" # Echo the config 
    echo_ascii1

    while IFS= read -r script_module # read each line of the conif and run "script_module" on host(s).
	do	
        script_module="$(trim_line "$script_module")"
        if ! is_blank_or_comment "$script_module" && validate_module "$script_module" && should_run_module "$script_module"; then
            enqueue_module "$userAtHost" "$script_module" "$sshDelaySingleHost"
        fi
	done < "$configFile"
    wait # wait for each host to complete before proceeding. 
}


### Run ONE modules against ALL host(s) at a time. ### 
Run_LiveIR_Multi_Hosts() {   
    userAtHostList=$1
    configFile=$2
    local preflighted_hosts=""

    echo_ascii1
    echo_config "$configFile" # Echo the config 
    echo_ascii1
    while IFS= read -r script_module
    do	
        script_module="$(trim_line "$script_module")"
        if is_blank_or_comment "$script_module" || ! validate_module "$script_module" || ! should_run_module "$script_module"; then
            continue
        fi

        while IFS= read -r usernameAtHost
        do	
            usernameAtHost="$(trim_line "$usernameAtHost")"
            if ! is_blank_or_comment "$usernameAtHost" && validate_host "$usernameAtHost"; then
                if [[ " $preflighted_hosts " != *" $usernameAtHost "* ]]; then
                    run_host_preflight "$usernameAtHost"
                    preflighted_hosts="$preflighted_hosts $usernameAtHost"
                fi
                enqueue_module "$usernameAtHost" "$script_module" "$sshDelayMultiHost"
            fi
        done < "$userAtHostList"    
        wait # wait for hosts to complete before proceeding to the next module. 
    
    done < "$configFile"

}

error_message(){
    echo_ascii1
    echo ""
    echo "!!! ERROR !!! -- S0m3 7h1ng w3n7 wr0ng. "
	echo "Please run birtha.sh as follows: "
	echo "$ ./birtha.sh <user@hostname> "
    echo "$ ./birtha.sh <user@hostname> [</path/to/birthaConfig.conf>] "
	echo "$ ./birtha.sh </path/to/hostlist.txt> (*Host list should contain one user@hostname per line.)"
    echo "$ ./birtha.sh </path/to/hostlist.txt> [</path/to/config.conf>]  "
    echo "$ ./birtha.sh --dry-run </path/to/hostlist.txt> [</path/to/config.conf>]  "
    echo "$ ./birtha.sh --max-jobs 8 </path/to/hostlist.txt> [</path/to/config.conf>]  "
    echo "$ ./birtha.sh --allow-changes <user@hostname> </path/to/modifying-config.conf>  "
    echo "$ ./birtha.sh --validate [<user@hostname>|</path/to/hostlist.txt>] </path/to/config.conf>  "
    echo "$ ./birtha.sh --local [</path/to/config.conf>]  "
    echo "$ ./birtha.sh --local-host --profile macos-compromise  "
    echo "$ ./birtha.sh --timeout 60 <user@hostname> [</path/to/config.conf>]  "
    echo "$ ./birtha.sh --post-report html <user@hostname> [</path/to/config.conf>]  "
    echo "$ ./birtha.sh --post-report html --all-findings <user@hostname> [</path/to/config.conf>]  "
    echo "$ ./birtha.sh --post-report html --finding-limit 100 <user@hostname> [</path/to/config.conf>]  "
    echo "$ ./birtha.sh --post-report markdown --local-host --profile macos-compromise  "
    echo "$ ./birtha.sh --list-modules [--os macos] [--category persistence]  "
    echo "$ ./birtha.sh --profile macos-compromise <user@hostname>  "
    echo "$ ./birtha.sh --case CASE-001 --operator analyst --ticket INC-001 <user@hostname> [</path/to/config.conf>]  "
    echo "$ ./birtha.sh --resume <Results/run_dir> <user@hostname> [</path/to/config.conf>]  "
    exit
}

#
#Run_Analysis() { # examp. cat ./Results/Fri_26_Feb_2021_11.03.32_PM_CST/cat_passwd/*
#    #while IFS= read -r line
#        cat "./Results/$timestamp/$script_module/"
#    #done < "$configFile"
#}


POSITIONAL_ARGS=()
while [ "$#" -gt 0 ]; do
    case "$1" in
        --dry-run|-dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        --allow-changes)
            ALLOW_CHANGES=true
            shift
            ;;
        --validate)
            VALIDATE_ONLY=true
            shift
            ;;
        --local|--local-host|--localhost)
            LOCAL_MODE=true
            shift
            ;;
        --list-modules)
            LIST_MODULES=true
            shift
            ;;
        --profile)
            shift
            PROFILE="${1:-}"
            [[ -n "$PROFILE" ]] || { echo "!!! ERROR !!! -- --profile requires a value" >&2; exit 1; }
            shift
            ;;
        --profile=*)
            PROFILE="${1#*=}"
            shift
            ;;
        --case)
            shift
            CASE_ID="${1:-}"
            [[ -n "$CASE_ID" ]] || { echo "!!! ERROR !!! -- --case requires a value" >&2; exit 1; }
            shift
            ;;
        --case=*)
            CASE_ID="${1#*=}"
            shift
            ;;
        --operator)
            shift
            OPERATOR="${1:-}"
            [[ -n "$OPERATOR" ]] || { echo "!!! ERROR !!! -- --operator requires a value" >&2; exit 1; }
            shift
            ;;
        --operator=*)
            OPERATOR="${1#*=}"
            shift
            ;;
        --ticket)
            shift
            TICKET="${1:-}"
            [[ -n "$TICKET" ]] || { echo "!!! ERROR !!! -- --ticket requires a value" >&2; exit 1; }
            shift
            ;;
        --ticket=*)
            TICKET="${1#*=}"
            shift
            ;;
        --notes)
            shift
            NOTES="${1:-}"
            [[ -n "$NOTES" ]] || { echo "!!! ERROR !!! -- --notes requires a value" >&2; exit 1; }
            shift
            ;;
        --notes=*)
            NOTES="${1#*=}"
            shift
            ;;
        --strict-host-keys)
            STRICT_HOST_KEYS=true
            shift
            ;;
        --known-hosts)
            shift
            KNOWN_HOSTS_FILE="${1:-}"
            [[ -n "$KNOWN_HOSTS_FILE" ]] || { echo "!!! ERROR !!! -- --known-hosts requires a value" >&2; exit 1; }
            shift
            ;;
        --known-hosts=*)
            KNOWN_HOSTS_FILE="${1#*=}"
            shift
            ;;
        --identity-file|-i)
            shift
            IDENTITY_FILE="${1:-}"
            [[ -n "$IDENTITY_FILE" ]] || { echo "!!! ERROR !!! -- --identity-file requires a value" >&2; exit 1; }
            shift
            ;;
        --identity-file=*)
            IDENTITY_FILE="${1#*=}"
            shift
            ;;
        --resume)
            shift
            RESUME_RUN="${1:-}"
            [[ -n "$RESUME_RUN" ]] || { echo "!!! ERROR !!! -- --resume requires a value" >&2; exit 1; }
            shift
            ;;
        --resume=*)
            RESUME_RUN="${1#*=}"
            shift
            ;;
        --retry-failed)
            RETRY_FAILED=true
            shift
            ;;
        --no-preflight)
            RUN_PREFLIGHT=false
            shift
            ;;
        --post-report)
            shift
            POST_REPORT="${1:-}"
            [[ -n "$POST_REPORT" ]] || { echo "!!! ERROR !!! -- --post-report requires a value" >&2; exit 1; }
            shift
            ;;
        --post-report=*)
            POST_REPORT="${1#*=}"
            shift
            ;;
        --html-report)
            POST_REPORT="html"
            shift
            ;;
        --markdown-report)
            POST_REPORT="markdown"
            shift
            ;;
        --executive-report)
            POST_REPORT="report"
            shift
            ;;
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
        --os)
            shift
            if [ -z "$1" ]; then
                echo "!!! ERROR !!! -- --os requires a value" >&2
                exit 1
            fi
            LIST_FILTER_OS="$1"
            shift
            ;;
        --os=*)
            LIST_FILTER_OS="${1#*=}"
            shift
            ;;
        --category)
            shift
            if [ -z "$1" ]; then
                echo "!!! ERROR !!! -- --category requires a value" >&2
                exit 1
            fi
            LIST_FILTER_CATEGORY="$1"
            shift
            ;;
        --category=*)
            LIST_FILTER_CATEGORY="${1#*=}"
            shift
            ;;
        --timeout)
            shift
            if [ -z "$1" ]; then
                echo "!!! ERROR !!! -- --timeout requires a value" >&2
                exit 1
            fi
            MODULE_TIMEOUT="$1"
            shift
            ;;
        --timeout=*)
            MODULE_TIMEOUT="${1#*=}"
            shift
            ;;
        --max-jobs)
            shift
            if [ -z "$1" ]; then
                echo "!!! ERROR !!! -- --max-jobs requires a value" >&2
                exit 1
            fi
            MAX_JOBS="$1"
            shift
            ;;
        --max-jobs=*)
            MAX_JOBS="${1#*=}"
            shift
            ;;
        --help|-h)
            error_message
            ;;
        --)
            shift
            while [ "$#" -gt 0 ]; do
                POSITIONAL_ARGS+=("$1")
                shift
            done
            ;;
        -*)
            echo "!!! ERROR !!! -- Unknown option: $1" >&2
            error_message
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done
set -- "${POSITIONAL_ARGS[@]}"

validate_max_jobs
validate_timeout
validate_post_report_format
validate_report_finding_options
configure_results_and_ssh

if [[ "$LIST_MODULES" == true ]]; then
    list_modules
    exit 0
fi

if [[ "$LOCAL_MODE" == true && -z "$1" ]]; then
    set -- "localhost" "$DEFAULT_CONFIG"
elif [[ "$LOCAL_MODE" == true && -n "$1" && -z "${2:-}" && -f "$1" ]]; then
    set -- "localhost" "$1"
elif [[ "$LOCAL_MODE" == true && -n "$1" ]]; then
    reverseit_local="$(printf '%s' "$1" | rev)"
    inputs_extension_local="$(printf '%s' "$reverseit_local" | cut -d'.' -f1 | rev)"
    if [[ "$inputs_extension_local" == "conf" ]]; then
        set -- "localhost" "$1"
    fi
fi

if test -z "$1"; then # $1 is a positional parameter
	# then $1 is null 
	error_message
else 
    reverseit=$(printf '%s' "$1" | rev) # reverse the order of the string to get the extension first 
    inputs_extension=$(printf '%s' "$reverseit" | cut -d'.' -f1 | rev) # cut on the '.' and reverse the extension back 
    
    if [ "$inputs_extension" == "txt" ]; then 
        echo "      [ HOST FILE: $1 ]"
        [[ "$DRY_RUN" == true || "$VALIDATE_ONLY" == true ]] || sleep 1
    elif [ "$inputs_extension" == "conf" ] && [[ "$VALIDATE_ONLY" != true && "$LOCAL_MODE" != true ]]; then 
        echo "Position 1 is a config (conf) file"
        error_message
        sleep 1
        exit
    fi

fi 

# IF config file param is null, then run the default config 
if [[ "$VALIDATE_ONLY" == true && "$inputs_extension" == "conf" ]]; then
    validationTarget=""
    configFile="$1"
else
    validationTarget="$1"
    configFile="${2:-$DEFAULT_CONFIG}"
fi

if [[ -n "$PROFILE" ]]; then
    if ! configFile="$(profile_config "$PROFILE")"; then
        echo "!!! ERROR !!! -- Unknown profile: $PROFILE" >&2
        echo "Known profiles: fast, standard, macos-initial, macos-compromise, macos-persistence, linux-ssh-compromise, linux-compromise, unix-compromise, cryptominer, forensic-deep" >&2
        exit 1
    fi
fi

check_config "$configFile" #Check config file exists function 
if [[ "$VALIDATE_ONLY" == true ]]; then
    run_validation "$validationTarget" "$configFile"
    exit $?
fi

if [[ "$DRY_RUN" == true ]]; then
    echo "      [ DRY-RUN MODE: ENABLED - no SSH commands will run and no Results directory will be created ]"
    echo "      [ Max Jobs: $MAX_JOBS ]"
    echo "      [ Timeout Seconds: $MODULE_TIMEOUT ]"
    if [[ "$LOCAL_MODE" == true ]]; then
        echo "      [ Local mode: ENABLED - modules run directly on this host; SSH is not used ]"
    fi
    if [[ "$ALLOW_CHANGES" == true ]]; then
        echo "      [ System-changing modules: ALLOWED ]"
    else
        echo "      [ System-changing modules: BLOCKED unless --allow-changes is set ]"
    fi
else
    init_results
    write_case_manifest "$configFile"
    if [[ "$LOCAL_MODE" == true ]]; then
        echo "      [ Local mode: ENABLED - modules run directly on this host; SSH is not used ]"
    fi
    if [[ -n "$CASE_ID" ]]; then
        echo "      [ Case: $CASE_ID ]"
    fi
    if [[ -n "$RESUME_RUN" ]]; then
        echo "      [ Resume run: $RESUME_RUN ]"
    fi
    echo "      [ Timeout Seconds: $MODULE_TIMEOUT ]"
    if [[ "$ALLOW_CHANGES" == true ]]; then
        echo "      [ System-changing modules: ALLOWED ]"
    fi
fi

 
## Script starts running here ##
################################
if test -f "$1"; then  # Check If file (hostlist) exists 
    if [[ ! -r "$1" ]]; then
        echo "!!! ERROR !!! -- Host list not readable: $1" >&2
        exit 1
    fi
    hostcount="$(count_active_hosts "$1")"
    if [ "$hostcount" -eq 0 ]; then
        echo "!!! ERROR !!! -- Host list has no active hosts: $1" >&2
        exit 1
    fi
    if [ "$hostcount" -ge "$multiHostNumber" ]; then 
        echo "      [ Host Count: $hostcount ]"
        if [ "$hostcount" -gt "$multiHostMax" ]; then
            echo "!!! ERROR !!! -- Host count $hostcount exceeds multiHostMax $multiHostMax" >&2
            exit 1
        fi
        [[ "$DRY_RUN" == true ]] || sleep 2
        echo "      [ Mutiple Host mode: ENABLED ] "
        [[ "$DRY_RUN" == true ]] || sleep 2
        Run_LiveIR_Multi_Hosts "$1" "$configFile"
    else 
        while IFS= read -r userAtHost
        do	
            userAtHost="$(trim_line "$userAtHost")"
            if ! is_blank_or_comment "$userAtHost"; then
                #call Run_LiveIR function for each host in the hostlist ($1)
                Run_LiveIR "$userAtHost" "$configFile"
            fi
        done <"$1"
    fi 
else #Else it must be a userName@hostName/ip     
    #call Run_LiveIR function
    Run_LiveIR "$1" "$configFile"
fi 

echo " "
if [[ "$DRY_RUN" == true ]]; then
    echo ">> Dry run complete. No SSH commands were executed."
else
    echo ">> Results can be Found in the 'Results' Folder: "
    echo "------------------------------------------------ "
    echo " --> '$RESULTS_ROOT/{ *HERE* }'"
    post_report_rc=0
    if [[ -n "$POST_REPORT" ]]; then
        run_post_report "$POST_REPORT" || post_report_rc=$?
    fi
    failed_runs="$(count_failed_module_runs)"
    if [ "$failed_runs" -gt 0 ]; then
        echo ">> WARNING: $failed_runs module run(s) failed or timed out. Review run_manifest.tsv and stderr.txt files."
        exit 2
    fi
    if [ "$post_report_rc" -ne 0 ]; then
        echo ">> WARNING: post-collection report generation failed with exit code $post_report_rc." >&2
        exit "$post_report_rc"
    fi
fi
echo " "
