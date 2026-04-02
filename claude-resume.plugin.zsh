# claude-resume: fzf-powered Claude Code session picker
# Usage: cresume [filter]  or  cresume bodo<TAB>

_cresume_sessions() {
  emulate -L zsh
  setopt NO_XTRACE NO_VERBOSE
  local filter="${1:-}"
  local projects_dir="$HOME/.claude/projects"

  [[ -d "$projects_dir" ]] || return 1

  # All locals declared upfront — declaring local inside for loops causes zsh
  # to echo the variable assignment to stdout on each scope transition
  local project_dir dirname jsonl_file session_id parsed
  local ts branch cwd msg_text short_cwd rest1 rest2

  for project_dir in "$projects_dir"/*/; do
    dirname="${project_dir:t}"

    if [[ -n "$filter" ]] && [[ "${dirname:l}" != *"${filter:l}"* ]]; then
      continue
    fi

    for jsonl_file in "$project_dir"*.jsonl(N); do
      session_id="${jsonl_file:t:r}"

      parsed=$(head -40 "$jsonl_file" 2>/dev/null | python3 -c "
import json, sys

def extract_text(content):
    if isinstance(content, list):
        parts = []
        for b in content:
            if not isinstance(b, dict):
                continue
            if b.get('type') == 'text':
                t = b.get('text', '').strip()
                if t.startswith('<') and '>' in t:
                    continue
                parts.append(t)
        return ' '.join(parts)
    text = str(content).strip()
    if text.startswith('<') and '>' in text:
        return ''
    return text

for line in sys.stdin:
    try:
        d = json.loads(line)
        if d.get('type') == 'user' and d.get('userType') == 'external':
            text = extract_text(d.get('message', {}).get('content', ''))
            if not text:
                continue
            text = text.replace('\n', ' ').replace('\t', ' ')[:80]
            cwd = d.get('cwd', '')
            branch = d.get('gitBranch', '') or ''
            ts = d.get('timestamp', '')[:10]
            print(ts + '\t' + branch + '\t' + cwd + '\t' + text)
            break
    except Exception:
        continue
" 2>/dev/null)

      [[ -z "$parsed" ]] && continue

      ts="${parsed%%$'\t'*}"
      rest1="${parsed#*$'\t'}"
      branch="${rest1%%$'\t'*}"
      rest2="${rest1#*$'\t'}"
      cwd="${rest2%%$'\t'*}"
      msg_text="${rest2#*$'\t'}"

      short_cwd="${cwd:h:t}/${cwd:t}"

      # Format: display<TAB>cwd<TAB>session_id
      printf '%-10s  %-30s  %-35s  %s\t%s\t%s\n' \
        "$ts" \
        "${branch:0:30}" \
        "${short_cwd:0:35}" \
        "${msg_text:0:80}" \
        "$cwd" \
        "$session_id"
    done
  done
}

_cresume_pick() {
  local filter="${1:-}"
  _cresume_sessions "$filter" \
    | sort -r \
    | fzf \
        --delimiter $'\t' \
        --with-nth 1 \
        --query "$filter" \
        --prompt 'claude> ' \
        --height '50%' \
        --reverse \
        --no-sort
}

cresume() {
  local filter="${1:-}"
  local selected rest cwd session_id
  selected=$(_cresume_pick "$filter") || return 0
  [[ -z "$selected" ]] && return 0

  rest="${selected#*$'\t'}"
  cwd="${rest%%$'\t'*}"
  session_id="${rest#*$'\t'}"

  print -z "cd '${cwd}' && claude --resume ${session_id}"
}

