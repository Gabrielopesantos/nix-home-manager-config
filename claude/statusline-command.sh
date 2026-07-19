#!/usr/bin/env bash
# Claude Code status line script
# Displays: model | context current/max (%) | 5h limit (%) | cost | style/vim

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown model"')

used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
max_tokens=$(echo "$input" | jq -r '.context_window.context_window_size // 0')

rl_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')

output_style=$(echo "$input" | jq -r '.output_style.name // empty')
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')

fmt_k() {
  local n=$1
  if [ "$n" -ge 1000 ]; then
    awk "BEGIN { printf \"%gk\", $n / 1000 }"
  else
    echo "$n"
  fi
}

pct_color() {
  local pct=$1
  if [ "$pct" -ge 80 ]; then
    echo "\033[0;31m"
  elif [ "$pct" -ge 50 ]; then
    echo "\033[0;33m"
  else
    echo "\033[0;32m"
  fi
}

ctx_segment=""
if [ -n "$used_pct" ] && [ "$max_tokens" -gt 0 ]; then
  used_int=$(printf "%.0f" "$used_pct")
  ctx_color=$(pct_color "$used_int")
  used_tokens=$(awk "BEGIN { printf \"%.0f\", ($used_pct / 100) * $max_tokens }")
  cur_fmt=$(fmt_k "$used_tokens")
  max_fmt=$(fmt_k "$max_tokens")
  ctx_segment="${ctx_color}ctx:${cur_fmt}/${max_fmt} (${used_int}%)\033[0m"
fi

rl_segment=""
if [ -n "$rl_pct" ]; then
  rl_int=$(printf "%.0f" "$rl_pct")
  rl_color=$(pct_color "$rl_int")
  rl_segment="${rl_color}5h:${rl_int}%\033[0m"
fi

cost_segment=""
[ -n "$cost_usd" ] && cost_segment=$(awk "BEGIN { printf \"\$%.2f\", $cost_usd }")

skills=""
[ -n "$output_style" ] && [ "$output_style" != "default" ] && skills="style:${output_style}"
[ -n "$vim_mode" ] && skills="${skills:+$skills }vim:${vim_mode}"

dim="\033[2m"
reset="\033[0m"
sep="${dim} | ${reset}"

line="${dim}${model}${reset}"

[ -n "$ctx_segment" ]  && line="${line}${sep}${ctx_segment}"
[ -n "$rl_segment" ]   && line="${line}${sep}${rl_segment}"
[ -n "$cost_segment" ] && line="${line}${sep}${dim}${cost_segment}${reset}"
[ -n "$skills" ]       && line="${line}${sep}${dim}${skills}${reset}"

printf "%b\n" "${line}"
