```bash
# Install Node (needed for Claude Code CLI)
curl -fsSL https://fnm.vercel.app/install | bash
source ~/.bashrc
fnm install 20
fnm use 20

# Install Claude Code
npm install -g @anthropic-ai/claude-code

# Install gh CLI
# On SteamOS (Arch-based), use the AUR or direct binary:
curl -sS https://webi.sh/gh | sh

# Auth
gh auth login

# Clone the repo into the Teardown mods folder
cd ~/.local/share/Teardown/mods/
git clone https://github.com/yohoGDES/teardown-playground.git
cd teardown-playground

# Launch Claude Code
claude
```