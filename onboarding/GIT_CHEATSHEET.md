# Git & GitHub Cheatsheet

Copy-paste commands for the git/hub basics you need during a hackathon.

---

## First Time Setup (do once)

```bash
# Set your name and email
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

# Set default branch name
git config --global init.defaultBranch main

# Install GitHub CLI (macOS)
brew install gh

# Install GitHub CLI (Linux)
sudo apt install gh

# Login to GitHub
gh auth login
```

---

## Creating a Repo

### Option 1: Start locally, push to GitHub

```bash
# Initialize git in your project folder
git init

# Add all files and commit
git add .
git commit -m "initial commit"

# Create repo on GitHub and push
gh repo create my-project --public --source=. --push
```

### Option 2: Create on GitHub first, then clone

```bash
# Create repo on GitHub
gh repo create my-project --public

# Clone it
git clone https://github.com/your-username/my-project.git
cd my-project

# Start working...
```

---

## Daily Workflow

```bash
# Clone a repo
git clone https://github.com/user/repo.git
cd repo

# Create a branch for your work
git checkout -b feat/my-feature

# Stage changes
git add .                  # Everything
git add file.py            # One file
git add src/               # One directory

# Commit
git commit -m "feat: add user auth"

# Push to remote
git push -u origin feat/my-feature

# Pull latest changes
git pull origin main

# See what's changed
git status
git diff
```

---

## Branching

```bash
# Create and switch to new branch
git checkout -b feat/my-feature

# List branches
git branch                 # Local
git branch -r              # Remote
git branch -a              # All

# Switch branch
git checkout main
git checkout feat/my-feature

# Delete branch (merged)
git branch -d feat/my-feature

# Delete branch (remote)
git push origin --delete feat/my-feature
```

---

## Undoing Things

```bash
# Undo changes to a file (before staging)
git checkout -- file.py

# Unstage a file (after git add)
git reset HEAD file.py

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes) — DANGER
git reset --hard HEAD~1

# Stash changes (save for later)
git stash
git stash pop

# See stash list
git stash list
```

---

## GitHub CLI

```bash
# Create a repo
gh repo create my-project --public --source=. --push

# Create a pull request
gh pr create --title "feat: add auth" --body "Adds user authentication"

# List pull requests
gh pr list

# View a pull request
gh pr view 123

# Merge a pull request
gh pr merge 123

# Clone a repo
gh repo clone user/repo

# View issues
gh issue list

# Create an issue
gh issue create --title "Bug: login fails" --body "Steps to reproduce..."
```

---

## Common Emergencies

### Merge conflict

```bash
# See conflicting files
git status

# Edit the files, fix the conflicts (look for <<<<<<<< and >>>>>>>)

# After fixing
git add .
git commit -m "fix: resolve merge conflict"
```

### Pushed secrets (API keys, passwords)

```bash
# Immediately rotate the secret on the provider

# Remove from git history
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch .env' \
  --prune-empty --tag-name-filter cat -- --all

# Force push
git push --force

# Add to .gitignore
echo ".env" >> .gitignore
git add .gitignore
git commit -m "chore: remove .env from tracking"
```

### Wrong branch

```bash
# Committed to main, should be on a feature branch
git branch feat/my-feature          # Create branch at current commit
git reset --hard origin/main        # Move main back
git checkout feat/my-feature        # Switch to feature branch
```

### Lost a commit

```bash
# Find the commit hash
git reflog

# Restore it
git checkout <commit-hash>
# or
git cherry-pick <commit-hash>
```

---

## Conventional Commits

```
feat: add user authentication
fix: resolve login timeout
docs: update onboarding guide
chore: add docker-compose
refactor: simplify auth logic
test: add login tests
style: format code with black
ci: add GitHub Actions workflow
```

---

## Quick Reference

| Command | What it does |
|---|---|
| `git status` | See what's changed |
| `git log --oneline` | See recent commits |
| `git diff` | See unstaged changes |
| `git diff --staged` | See staged changes |
| `git blame file.py` | See who changed what |
| `git log --oneline --graph` | Visual branch history |
