# Linux Commands Cheatsheet

Basic commands that make startup faster. Copy-paste friendly.

---

## Navigation

| Command | What it does | Example |
|---|---|---|
| `cd dir` | Change directory | `cd src/` |
| `cd ..` | Go up one directory | `cd ..` |
| `cd ~` | Go to home directory | `cd ~` |
| `pwd` | Print current directory | `pwd` |
| `ls` | List files | `ls` |
| `ls -la` | List all files (including hidden) | `ls -la` |
| `ls -lh` | List with human-readable sizes | `ls -lh` |

---

## File Operations

| Command | What it does | Example |
|---|---|---|
| `touch file` | Create empty file | `touch app.py` |
| `mkdir dir` | Create directory | `mkdir src` |
| `mkdir -p dir/sub` | Create nested directories | `mkdir -p src/routes` |
| `cp src dest` | Copy file | `cp app.py app_backup.py` |
| `cp -r src dest` | Copy directory recursively | `cp -r src/ src_backup/` |
| `mv src dest` | Move or rename file | `mv old.py new.py` |
| `rm file` | Delete file | `rm temp.txt` |
| `rm -r dir` | Delete directory | `rm -r build/` |
| `rm -rf dir` | Force delete (no confirmation) | `rm -rf node_modules/` |

---

## Reading Files

| Command | What it does | Example |
|---|---|---|
| `cat file` | Print entire file | `cat README.md` |
| `head file` | Print first 10 lines | `head app.py` |
| `head -n 20 file` | Print first 20 lines | `head -n 20 app.py` |
| `tail file` | Print last 10 lines | `tail app.py` |
| `tail -f file` | Follow file (watch changes) | `tail -f logs/app.log` |
| `less file` | Scroll through file | `less app.py` |
| `wc -l file` | Count lines | `wc -l app.py` |

---

## Writing Files

| Command | What it does | Example |
|---|---|---|
| `echo "text"` | Print text | `echo "Hello"` |
| `echo "text" > file` | Write to file (overwrite) | `echo "hello" > out.txt` |
| `echo "text" >> file` | Append to file | `echo "line 2" >> out.txt` |
| `echo $VAR` | Print environment variable | `echo $PATH` |
| `echo $VAR > file` | Save variable to file | `echo $DATABASE_URL > .env` |

---

## Searching

| Command | What it does | Example |
|---|---|---|
| `find . -name "*.py"` | Find files by name | `find . -name "*.py"` |
| `find . -type d -name "src"` | Find directories | `find . -type d -name "src"` |
| `grep "text" file` | Search in file | `grep "import" app.py` |
| `grep -r "text" dir` | Search recursively | `grep -r "TODO" src/` |
| `grep -i "text" file` | Case-insensitive search | `grep -i "error" logs.txt` |
| `which command` | Find command location | `which python` |
| `whereis command` | Find command + man pages | `whereis docker` |

---

## Permissions

| Command | What it does | Example |
|---|---|---|
| `chmod +x file` | Make file executable | `chmod +x deploy.sh` |
| `chmod 755 file` | Owner: rwx, Others: r-x | `chmod 755 app.py` |
| `chmod 644 file` | Owner: rw-, Others: r-- | `chmod 644 config.json` |
| `chown user file` | Change owner | `chown ubuntu app.py` |

### Common permissions

| Number | Permission | Use for |
|---|---|---|
| `755` | rwxr-xr-x | Executables, scripts |
| `644` | rw-r--r-- | Regular files |
| `700` | rwx------ | Private directories |

---

## Process Management

| Command | What it does | Example |
|---|---|---|
| `ps` | List processes | `ps aux` |
| `ps aux | grep python` | Find Python processes | `ps aux | grep uvicorn` |
| `top` | Live process monitor | `top` |
| `htop` | Better process monitor | `htop` |
| `kill PID` | Kill process | `kill 1234` |
| `kill -9 PID` | Force kill | `kill -9 1234` |
| `killall name` | Kill by name | `killall python` |

---

## Networking

| Command | What it does | Example |
|---|---|---|
| `curl url` | HTTP request | `curl http://localhost:8000/health` |
| `curl -X POST url` | POST request | `curl -X POST http://localhost:8000/docs` |
| `curl -d 'data' url` | POST with data | `curl -d '{"key":"val"}' -H "Content-Type: application/json" url` |
| `wget url` | Download file | `wget https://example.com/file.zip` |
| `ping host` | Test connectivity | `ping google.com` |
| `netstat -tlnp` | List listening ports | `netstat -tlnp` |
| `ss -tlnp` | List listening ports (newer) | `ss -tlnp` |
| `lsof -i :8000` | Find what's using port 8000 | `lsof -i :8000` |

---

## Docker Shortcuts

| Command | What it does | Example |
|---|---|---|
| `docker ps` | List running containers | `docker ps` |
| `docker ps -a` | List all containers | `docker ps -a` |
| `docker logs ID` | View container logs | `docker logs abc123` |
| `docker logs -f ID` | Follow logs | `docker logs -f abc123` |
| `docker exec -it ID bash` | Shell into container | `docker exec -it abc123 bash` |
| `docker-compose up` | Start services | `docker-compose up -d` |
| `docker-compose down` | Stop services | `docker-compose down -v` |
| `docker system prune` | Clean up Docker | `docker system prune -a` |

---

## Shell Shortcuts

| Shortcut | What it does |
|---|---|
| `Ctrl+C` | Stop current command |
| `Ctrl+Z` | Suspend current command |
| `Ctrl+R` | Search command history |
| `Ctrl+A` | Jump to start of line |
| `Ctrl+E` | Jump to end of line |
| `Ctrl+U` | Clear line |
| `Ctrl+L` | Clear screen |
| `Tab` | Autocomplete |
| `!!` | Repeat last command |
| `!$` | Last argument of previous command |

---

## Pipes and Redirects

| Symbol | What it does | Example |
|---|---|---|
| `|` | Pipe output to next command | `cat file.txt | grep "error"` |
| `>` | Write output to file (overwrite) | `echo "hello" > out.txt` |
| `>>` | Append output to file | `echo "more" >> out.txt` |
| `&&` | Run next if previous succeeds | `mkdir dir && cd dir` |
| `||` | Run next if previous fails | `cd dir || echo "not found"` |
| `2>&1` | Redirect errors to stdout | `command 2>&1 | grep "error"` |

---

## Combining Commands

```bash
# Create directory and enter it
mkdir -p src/routes && cd src/routes

# Find and kill a process
kill $(ps aux | grep "uvicorn" | grep -v grep | awk '{print $2}')

# Check if a port is in use
lsof -i :8000 || echo "Port 8000 is free"

# Run command and save output with timestamp
date > deploy.log && docker-compose up -d >> deploy.log 2>&1
```
