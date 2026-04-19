#!/usr/bin/env bash
# Claude Code status line script
# Displays: model | context current/max (%) | style/vim

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown model"')

used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
max_tokens=$(echo "$input" | jq -r '.context_window.context_window_size // 0')

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

ctx_segment=""
if [ -n "$used_pct" ] && [ "$max_tokens" -gt 0 ]; then
  used_int=$(printf "%.0f" "$used_pct")
  if [ "$used_int" -ge 80 ]; then
    ctx_color="\033[0;31m"
  elif [ "$used_int" -ge 50 ]; then
    ctx_color="\033[0;33m"
  else
    ctx_color="\033[0;32m"
  fi
  used_tokens=$(awk "BEGIN { printf \"%.0f\", ($used_pct / 100) * $max_tokens }")
  cur_fmt=$(fmt_k "$used_tokens")
  max_fmt=$(fmt_k "$max_tokens")
  ctx_segment="${ctx_color}ctx:${cur_fmt}/${max_fmt} (${used_int}%)\033[0m"
fi

skills=""
[ -n "$output_style" ] && [ "$output_style" != "default" ] && skills="style:${output_style}"
[ -n "$vim_mode" ] && skills="${skills:+$skills }vim:${vim_mode}"

dim="\033[2m"
reset="\033[0m"
sep="${dim} | ${reset}"

line="${dim}${model}${reset}"

[ -n "$ctx_segment" ] && line="${line}${sep}${ctx_segment}"
[ -n "$skills" ]      && line="${line}${sep}${dim}${skills}${reset}"

printf "%b\n" "${line}"
