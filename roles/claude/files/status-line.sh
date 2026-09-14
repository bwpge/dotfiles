#!/bin/bash

input=$(cat)
NOW=$(date +%s)

SEP="·"
RESET=$'\033[0m'

RAMP=(
    "74;222;128" "73;223;123" "71;224;104" "66;228;67" "113;234;59"
    "190;241;49" "251;191;36" "253;152;52" "254;120;69" "255;95;86"
)

mapfile -t fields < <(jq -r '
    def pct:
        if type == "number" then (round | tostring) else "" end;
    def epoch:
        if   type == "number" then (floor | tostring)
        elif type == "string" then (try (fromdateiso8601 | floor | tostring) catch "")
        else "" end;
    [
        (.model.display_name // "Unknown Model"),
        (.effort.level // ""),
        (.context_window.used_percentage | pct),
        (.rate_limits.five_hour.used_percentage | pct),
        (.rate_limits.five_hour.resets_at | epoch),
        (.workspace.current_dir // .worktree.original_cwd // "")
    ] | .[]
' <<< "$input" 2>/dev/null)

model="${fields[0]:-Unknown Model}"
effort="${fields[1]}"
ctx_pct="${fields[2]}"
rl_pct="${fields[3]}"
rl_reset="${fields[4]}"
workspace_dir="${fields[5]}"

make_bar() {
    local pct="$1" width=10 filled empty bar pad

    filled=$(( pct * width / 100 ))
    (( filled > width )) && filled=$width
    (( filled < 0 )) && filled=0
    empty=$(( width - filled ))

    printf -v bar '%*s' "$filled" ''
    bar="${bar// /█}"
    printf -v pad '%*s' "$empty" ''
    printf '%s%s' "$bar" "${pad// /░}"
}

format_bar() {
    local pct="$1" step

    [[ "$pct" =~ ^[0-9]+$ ]] || return 0

    step=$(( pct / 10 ))
    (( step > 9 )) && step=9

    printf '\033[38;2;%sm%s %s%%%s' "${RAMP[step]}" "$(make_bar "$pct")" "$pct" "$RESET"
}

format_time_delta() {
    local target="$1" delta days hours mins

    [[ "$target" =~ ^[0-9]+$ ]] || return 0
    delta=$(( target - NOW ))
    (( delta <= 0 )) && return 0

    days=$(( delta / 86400 ))
    hours=$(( delta / 3600 % 24 ))
    mins=$(( delta / 60 % 60 ))

    if   (( days > 0 && hours > 0 ));  then printf '%dd %dh' "$days" "$hours"
    elif (( days > 0 ));               then printf '%dd' "$days"
    elif (( hours > 0 && mins > 0 ));  then printf '%dh %dm' "$hours" "$mins"
    elif (( hours > 0 ));              then printf '%dh' "$hours"
    elif (( mins > 0 ));               then printf '%dm' "$mins"
    else                                    printf '<1m'
    fi
}

git_segment() {
    local dir="${1:-$PWD}"

    local I_BRANCH=$'\uea68 ' I_COMMIT=$'\uf417 ' I_TAG=$'\uf412 '
    local I_CHERRY=$'\ue29b ' I_MERGE=$'\ue727 ' I_REBASE=$'\ue728 '

    local gd gitdir commondir
    gd=$(git -C "$dir" rev-parse --absolute-git-dir --git-common-dir 2>/dev/null) || return 0
    gitdir=${gd%%$'\n'*}
    commondir=${gd##*$'\n'}
    [[ $commondir != /* ]] && commondir="$dir/$commondir"

    local out line xy ab
    local branch="" sha="" ahead=0 behind=0
    local staged=0 unstaged=0 untracked=0 unmerged=0

    out=$(GIT_OPTIONAL_LOCKS=0 git -C "$dir" status --porcelain=v2 --branch 2>/dev/null) || return 0

    while IFS= read -r line; do
        case "$line" in
            '# branch.oid '*)  sha="${line#\# branch.oid }" ;;
            '# branch.head '*) branch="${line#\# branch.head }" ;;
            '# branch.ab '*)
                ab="${line#\# branch.ab }"
                ahead="${ab%% *}";  ahead="${ahead#+}"
                behind="${ab##* }"; behind="${behind#-}"
                ;;
            '1 '*|'2 '*)
                xy="${line:2:2}"
                [[ "${xy:0:1}" != "." ]] && staged=$((staged + 1))
                [[ "${xy:1:1}" != "." ]] && unstaged=$((unstaged + 1))
                ;;
            'u '*) unmerged=$((unmerged + 1)) ;;
            '?'*)  untracked=$((untracked + 1)) ;;
        esac
    done <<< "$out"

    [[ "$sha" == "(initial)" ]] && sha=""

    local working=0 staging=0
    (( unstaged || untracked || unmerged )) && working=1
    (( staged )) && staging=1

    local stash=0
    if [[ -f "$commondir/logs/refs/stash" ]]; then
        while IFS= read -r line; do stash=$((stash + 1)); done < "$commondir/logs/refs/stash"
    fi

    local head tag n m hn
    if [[ -f "$gitdir/rebase-merge/head-name" ]]; then
        hn=$(<"$gitdir/rebase-merge/head-name"); hn=${hn#refs/heads/}
        n=0; m=0
        [[ -r "$gitdir/rebase-merge/msgnum" ]] && n=$(<"$gitdir/rebase-merge/msgnum")
        [[ -r "$gitdir/rebase-merge/end" ]]    && m=$(<"$gitdir/rebase-merge/end")
        head="${I_REBASE}${hn} ${n}/${m}"
    elif [[ -d "$gitdir/rebase-apply" ]]; then
        head="${I_REBASE}${branch}"
    elif [[ -f "$gitdir/CHERRY_PICK_HEAD" ]]; then
        head="${I_CHERRY}${branch}"
    elif [[ -f "$gitdir/MERGE_HEAD" ]]; then
        head="${I_MERGE}${branch}"
    elif [[ "$branch" == "(detached)" ]]; then
        tag=$(git -C "$dir" tag --points-at HEAD 2>/dev/null); tag=${tag%%$'\n'*}
        if [[ -n "$tag" ]]; then head="${I_TAG}${tag}"; else head="${I_COMMIT}${sha:0:7}"; fi
    else
        head="${I_BRANCH}${branch}"
    fi

    local color
    if   (( behind > 0 && ahead > 0 )); then color=35
    elif (( unmerged > 0 ));            then color=35
    elif (( untracked > 0 ));           then color=31
    elif (( working ));                 then color=33
    elif (( staging ));                 then color=34
    elif [[ -z "$sha" ]];               then color=90
    else                                     color=36
    fi

    local s=""
    if [[ -n "$sha" ]]; then s+="$head"; else s+="(new)"; fi
    (( working || staging ))                  && s+=" *"
    (( behind > 0 && ahead > 0 ))             && s+=" ↑↓"
    (( behind > 0 && ahead == 0 ))            && s+=" ↓"
    (( behind == 0 && ahead > 0 ))            && s+=" ↑"
    [[ -n "$sha" ]] && (( !working && !staging )) && s+=" ✓"
    (( stash > 0 ))                           && s+=" ⚑"

    printf '\033[%sm%s\033[0m' "$color" "$s"
}

segments=()
add_segment() { [[ -n "$1" ]] && segments+=("$1"); }

[[ -n "$effort" ]] && model="${model}, ${effort}"
model_seg="[${model}]"
ctx_bar="$(format_bar "$ctx_pct")"
[[ -n "$ctx_bar" ]] && model_seg+=" $ctx_bar"
add_segment "$model_seg"

rl_seg=""
if [[ ! "$rl_reset" =~ ^[0-9]+$ ]] || (( rl_reset > NOW )); then
    rl_bar="$(format_bar "$rl_pct")"
    rl_delta="$(format_time_delta "$rl_reset")"
    [[ -n "$rl_bar" ]] && rl_seg="$rl_bar"
    [[ -n "$rl_delta" ]] && rl_seg+="${rl_seg:+ }(resets in ${rl_delta})"
    [[ -n "$rl_seg" ]] && rl_seg="5h $rl_seg"
fi
add_segment "$rl_seg"

add_segment "$(git_segment "$workspace_dir")"

line=""
for segment in "${segments[@]}"; do
    line+="${line:+ $SEP }${segment}"
done
printf '%s' "$line"
