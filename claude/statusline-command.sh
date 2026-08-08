#!/usr/bin/env bash
# Claude Code status line script
# Model | cost (session/today/block+time-left/burn-rate) | context | style/vim
# Cost/time come from ccusage (reads local session logs), not Claude Code's own
# rate_limits/cost fields: rate_limits is Pro/Max-only and blank until the first
# API response, and cost.total_cost_usd reads 0 on some subscription plans.
# --no-offline: ccusage's bundled offline pricing table lags newest model
# releases (showed flat $0.00 for today/block on Sonnet 5 until switched to
# live pricing) - small network hit, cached per --refresh-interval.

input=$(cat)

ccusage_line=$(echo "$input" | ccusage statusline --no-offline --cost-source cc 2>/dev/null)
# Strip emoji/pictographs (incl. variation selector, ZWJ) that ccusage hardcodes
# into its output, and collapse the double space left behind.
ccusage_line=$(echo "$ccusage_line" | python3 -c '
import sys, re
line = sys.stdin.read()
line = re.sub(r"[\U0001F300-\U0001FAFF\U00002600-\U000027BF\U0001F1E6-\U0001F1FF️‍]", "", line)
line = re.sub(r" {2,}", " ", line).strip()
print(line)
')

output_style=$(echo "$input" | jq -r '.output_style.name // empty')
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')

skills=""
[ -n "$output_style" ] && [ "$output_style" != "default" ] && skills="style:${output_style}"
[ -n "$vim_mode" ] && skills="${skills:+$skills }vim:${vim_mode}"

line="$ccusage_line"
[ -n "$skills" ] && line="${line} | ${skills}"

printf "%s\n" "$line"
