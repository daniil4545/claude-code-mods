#!/usr/bin/env bash
# Claude Code status line (two lines)
#   1: model · directory · git branch · context bar
#   2: 5h / 7d / spend usage bars with reset countdowns

input=$(cat)
j() { echo "$input" | jq -r "$1 // empty"; }

model=$(j '.model.display_name')
cwd=$(j '.workspace.current_dir')
[ -z "$cwd" ] && cwd=$(j '.cwd')
dir_name=$(basename "${cwd:-~}")

ctx_used=$(j '.context_window.used_percentage')
ctx_size=$(j '.context_window.context_window_size')
ctx_tok=$(echo "$input" | jq -r '(.context_window.current_usage // {}) | ((.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0))')
if [ "${ctx_tok:-0}" = "0" ] && [ -n "$ctx_used" ] && [ -n "$ctx_size" ]; then
    ctx_tok=$(awk -v p="$ctx_used" -v s="$ctx_size" 'BEGIN{printf "%d", p*s/100}')
fi
five_pct=$(j '.rate_limits.five_hour.used_percentage')
five_reset=$(j '.rate_limits.five_hour.resets_at')
week_pct=$(j '.rate_limits.seven_day.used_percentage')
week_reset=$(j '.rate_limits.seven_day.resets_at')
spend_pct=$(j '.rate_limits.spend_limit.used_percentage')

branch="" dirty=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2> /dev/null)
    [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain -uno 2> /dev/null | head -1)" ] && dirty="*"
fi

# ---- Palette (256-color) ---------------------------------------------
c() { printf '\033[38;5;%sm' "$1"; }
R=$'\033[0m'
B=$'\033[1m'
C_MODEL=$(c 141)   # lavender
# warm Claude palette
C_BADGE=$'\033[1;38;2;217;119;87m'  # model: bold Claude orange
C_DIR=$'\033[38;2;245;230;211m'  # cream
C_GIT=$'\033[38;2;163;177;138m'  # sage green
C_DIRTY=$'\033[38;2;224;164;88m'  # honey
C_LABEL=$'\033[38;2;168;153;138m'  # warm grey
C_MUTED=$'\033[38;2;138;123;110m'  # dim warm grey
C_TRACK=$(c 237)   # bar track
C_OK=$'\033[38;2;163;177;138m'  # sage
C_WARN=$'\033[38;2;224;164;88m'  # honey
C_HOT=$'\033[38;2;229;83;75m'  # warm red
C_SEP=$'\033[38;2;92;74;61m'  # separator
# ---- Theme: ~/.claude/ui-themes/<active>.json overrides the colours above ----
THEME_DIR="$HOME/.claude/ui-themes"
theme_name=$(head -1 "$THEME_DIR/active" 2>/dev/null | tr -d '[:space:]')
theme_file="$THEME_DIR/${theme_name}.json"
hex_fg() { # hex_fg <#rrggbb> [bold] → ANSI truecolor foreground
    local h=${1#\#}
    [ ${#h} -eq 6 ] || return 1
    printf '\033[%s38;2;%d;%d;%dm' "${2:+1;}" "0x${h:0:2}" "0x${h:2:2}" "0x${h:4:2}"
}
if [ -n "$theme_name" ] && [ -f "$theme_file" ]; then
    tc() { jq -r ".statusline.$1 // empty" "$theme_file"; }
    v=$(tc model) && [ -n "$v" ] && C_BADGE=$(hex_fg "$v" bold)
    v=$(tc dir)   && [ -n "$v" ] && C_DIR=$(hex_fg "$v")
    v=$(tc git)   && [ -n "$v" ] && C_GIT=$(hex_fg "$v")
    v=$(tc dirty) && [ -n "$v" ] && C_DIRTY=$(hex_fg "$v")
    v=$(tc label) && [ -n "$v" ] && C_LABEL=$(hex_fg "$v")
    v=$(tc muted) && [ -n "$v" ] && C_MUTED=$(hex_fg "$v")
    v=$(tc ok)    && [ -n "$v" ] && C_OK=$(hex_fg "$v")
    v=$(tc warn)  && [ -n "$v" ] && C_WARN=$(hex_fg "$v")
    v=$(tc hot)   && [ -n "$v" ] && C_HOT=$(hex_fg "$v")
    v=$(tc sep)   && [ -n "$v" ] && C_SEP=$(hex_fg "$v")
fi
DOT=" ${C_SEP}·${R} "
GAP="   "

# ---- Helpers -----------------------------------------------------------
level_color() {
    local p=$1
    if [ "$p" -ge 80 ]; then printf '%s' "$C_HOT"
    elif [ "$p" -ge 50 ]; then printf '%s' "$C_WARN"
    else printf '%s' "$C_OK"; fi
}

# bar <pct> <width>  →  ━━━━━━━━ 42%
bar() {
    local pct width=$2 filled i out col
    pct=$(printf '%.0f' "$1")
    filled=$(((pct * width + 50) / 100))
    ((filled > width)) && filled=$width
    col=$(level_color "$pct")
    out="$col"
    for ((i = 0; i < filled; i++)); do out+="━"; done
    out+="$C_TRACK"
    for ((i = filled; i < width; i++)); do out+="━"; done
    printf '%s%s %s%3s%%%s' "$out" "$R" "$col" "$pct" "$R"
}

# until <epoch>  →  2h14m / 3d4h / 12m
until_str() {
    local diff=$(($1 - $(date +%s)))
    ((diff < 0)) && diff=0
    local d=$((diff / 86400)) h=$((diff % 86400 / 3600)) m=$((diff % 3600 / 60))
    if ((d > 0)); then printf '%dd%dh' "$d" "$h"
    elif ((h > 0)); then printf '%dh%02dm' "$h" "$m"
    else printf '%dm' "$m"; fi
}

# ---- Compact line (Nerd Font icons) -----------------------------------
# pct <value> → coloured "42%"
pct() {
    local p
    p=$(printf '%.0f' "$1")
    printf '%s%s%%%s' "$(level_color "$p")" "$p" "$R"
}


# chip <label> <pct> <reset> → "◷ 5h 42% 2h13m", text coloured by usage level (no background)
chip() {
    local p col
    p=$(printf '%.0f' "$2")
    col=$(level_color "$p")
    printf '%s%s %s%s%%%s' "$col" "$1" "$B" "$p" "$R"
    [ -n "$3" ] && printf ' %s%s%s' "$C_MUTED" "$3" "$R"
}

# model icon by family
case "${model,,}" in
    *opus*)   model_icon=$'\uf219' ;;  # diamond: the most capable
    *sonnet*) model_icon=$'\uf52d' ;;  # feather: a sonnet is a poem
    *haiku*)  model_icon=$'\uf0e7' ;;  # bolt: small and fast
    *fable*)  model_icon=$'\uf02d' ;;  # book: a fable is a story
    *)        model_icon=$'\uec19' ;;  # generic model chip
esac
# model colour by family: theme key statusline.model<Family>, falling back to statusline.model
case "${model,,}" in
    *opus*) fam=Opus ;; *sonnet*) fam=Sonnet ;; *haiku*) fam=Haiku ;; *fable*) fam=Fable ;; *) fam="" ;;
esac
if [ -n "$fam" ] && [ -f "${theme_file:-}" ]; then
    v=$(jq -r ".statusline.model$fam // empty" "$theme_file")
    [ -n "$v" ] && C_BADGE=$(hex_fg "$v" bold)
fi
line1="${C_BADGE}${model_icon} ${model:-unknown}${R}${DOT}${C_DIR} ${dir_name}${R}"
[ -n "$branch" ] && line1+="${DOT}${C_GIT} ${branch}${R}${C_DIRTY}${dirty}${R}"
if [ -n "$ctx_used" ]; then
    line1+="${DOT} $(pct "$ctx_used")"
    [ "${ctx_tok:-0}" -gt 0 ] 2>/dev/null && line1+=" ${C_LABEL}$(awk -v t="$ctx_tok" 'BEGIN{printf "%.0fK", t/1000}')${R}"
fi

parts=()
[ -n "$five_pct" ] && parts+=("$(chip ' 5h' "$five_pct" "${five_reset:+$(until_str "$five_reset")}")")
[ -n "$week_pct" ] && parts+=("$(chip '󰙺 7d' "$week_pct" "${week_reset:+$(until_str "$week_reset")}")")
[ -n "$spend_pct" ] && parts+=("$(chip '' "$spend_pct" "")")

usage=""
for p in "${parts[@]}"; do usage+="${usage:+$DOT}${p}"; done

# display width (emoji count as 2 columns)
plain_len() {
    printf '%s' "$1" | sed 's/\x1b\[[0-9;]*m//g' | LC_ALL=C.UTF-8 wc -L
}

# Left: model/folder/context. Right: limits, right-aligned on the same line.
# Falls back to a second line only when both don't fit.
MARGIN=6
if [ -z "$usage" ]; then
    printf '%s\n' "$line1"
    exit 0
fi
width=$(( ${COLUMNS:-0} - MARGIN ))
padding=$(( width - $(plain_len "$line1") - $(plain_len "$usage") ))
if (( ${COLUMNS:-0} > 0 && padding >= 3 )); then
    printf '%s%*s%s\n' "$line1" "$padding" "" "$usage"
else
    printf '%s\n%s\n' "$line1" "$usage"
fi
