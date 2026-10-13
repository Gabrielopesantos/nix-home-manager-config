#!/usr/bin/env bash
# Claude Code status line script
# Model | cost (session) | context % | rate limit (5h/7d) | ccusage (today/block/burn-rate) | style/vim
# Model/cost/context/rate-limit read from Claude Code's own statusline JSON
# (native fields, no network call, no pricing-table lag). ccusage is kept only
# for today-total/active-block+time-left/burn-rate, which the native JSON
# doesn't expose. --no-offline: ccusage's bundled offline pricing table lags
# newest model releases - small network hit, cached per --refresh-interval.

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name')
session_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
context_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
five_h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

session_cost_fmt=$(printf '$%.2f' "$session_cost")

limits=""
[ -n "$five_h" ] && limits="5h:$(printf '%.0f' "$five_h")%"
[ -n "$week" ] && limits="${limits:+$limits }7d:$(printf '%.0f' "$week")%"

ccusage_line=$(echo "$input" | ccusage statusline --no-offline --cost-source cc 2>/dev/null)
# Keep only the today/block/burn-rate segment ccusage alone provides, after
# stripping the emoji/pictographs (incl. variation selector, ZWJ) it hardcodes.
today_block=$(echo "$ccusage_line" | python3 -c '
import sys, re
line = sys.stdin.read()
line = re.sub(r"[\U0001F300-\U0001FAFF\U00002600-\U000027BF\U0001F1E6-\U0001F1FF️‍]", "", line)
line = re.sub(r" {2,}", " ", line)
m = re.search(r"\$[\d.]+ today / \$[\d.]+ block \([^)]*\) \| \$[\d.]+/hr", line)
print(m.group(0) if m else "")
')

output_style=$(echo "$input" | jq -r '.output_style.name // empty')
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')

skills=""
[ -n "$output_style" ] && [ "$output_style" != "default" ] && skills="style:${output_style}"
[ -n "$vim_mode" ] && skills="${skills:+$skills }vim:${vim_mode}"

line="$model | $session_cost_fmt session | ${context_pct}% context"
[ -n "$limits" ] && line="${line} | ${limits}"
[ -n "$today_block" ] && line="${line} | ${today_block}"
[ -n "$skills" ] && line="${line} | ${skills}"

printf "%s\n" "$line"
