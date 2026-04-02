# zsh-claude-resume

fzf-powered session picker for [Claude Code](https://claude.ai/code). Browse your past Claude sessions by project, see the git branch and first message, and resume directly in the right directory.

## Usage

```zsh
cresume             # show all sessions
cresume myproject   # filter sessions by project name
```

The picker shows date, git branch, project, and the first message of each session:

```
  claude> myproject
  2026-04-01  feature/auth-refactor       myapp/backend        implement JWT refresh token rotation
  2026-03-28  bugfix/fix-upload-encoding  myapp/backend        file uploads fail for filenames with spaces
  2026-03-25  develop                     myapp/frontend       why is the sidebar re-rendering on every keystroke
  2026-03-20  feature/onboarding-flow     myapp/frontend       build a multi-step onboarding wizard
```

After selecting a session, the command is inserted into your shell buffer (editable, not auto-executed):

```zsh
cd '/path/to/project' && claude --resume <session-id>
```

## Requirements

- [Claude Code](https://claude.ai/code)
- [fzf](https://github.com/junegunn/fzf)
- python3 (pre-installed on macOS)

## Installation

### oh-my-zsh

```zsh
git clone https://github.com/maluramichael/zsh-claude-resume \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/claude-resume
```

Then add `claude-resume` to your plugins in `~/.zshrc`:

```zsh
plugins=(... claude-resume)
```

### zinit

```zsh
zinit light maluramichael/zsh-claude-resume
```

### antigen

```zsh
antigen bundle maluramichael/zsh-claude-resume
```

### Manual

```zsh
git clone https://github.com/maluramichael/zsh-claude-resume ~/.zsh/plugins/claude-resume
echo 'source ~/.zsh/plugins/claude-resume/claude-resume.plugin.zsh' >> ~/.zshrc
```

Then reload: `source ~/.zshrc`
