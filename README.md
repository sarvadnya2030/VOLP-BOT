# VOLP Server Bot (Free + Open Source)

This bot tracks VOLP assignment uploads and due-date changes without needing your Chrome extension popup open.

It uses only open-source components:
- Python
- Playwright
- SQLite
- Telegram Bot API

## What it does

- Logs into VOLP automatically
- Crawls `learner/my-courses`, course links, and assignment routes
- Extracts assignment blocks anchored by `Question No.` + `Due Date`
- Stores state in SQLite (`state.db`)
- Sends Telegram alerts for:
  - New assignments
  - Due-date updates
- Sends one-time Telegram connection test on first valid run

### Robustness upgrades

- Page crawl with bounded BFS (`SCAN_MAX_PAGES`) to avoid missing nested assignment routes
- Retry logic for flaky page loads (`SCAN_RETRIES`)
- Request optimization by blocking heavy assets (images/fonts/media)
- Due-date normalization to UTC (`VOLP_TZ_OFFSET_MINUTES`) for stable update detection
- Differential alerts (new/updated only), backed by SQLite state

## 1) Local setup

```bash
cd server-bot
cp .env.example .env
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python -m playwright install chromium
```

Edit `.env` with:
- `VOLP_USERNAME`
- `VOLP_PASSWORD`
- `TELEGRAM_BOT_TOKEN`
- `TELEGRAM_CHAT_ID`

Optional tuning:
- `SCAN_MAX_PAGES` (default `40`)
- `SCAN_RETRIES` (default `2`)
- `VOLP_TZ_OFFSET_MINUTES` (default `330` for IST)

Run once:

```bash
python bot.py --once
```

Run continuously:

```bash
python bot.py --daemon
```

## 2) Free cloud option (recommended): GitHub Actions

This repo includes a scheduler workflow at:
- `.github/workflows/volp-server-bot.yml`

### Requirements for free usage
- Keep repo public (open source) to get free GitHub Actions minutes more reliably.

### Configure repository secrets

In GitHub repo settings → Secrets and variables → Actions, add:
- `VOLP_BASE_URL` = `https://classroom.volp.in`
- `VOLP_LOGIN_URL` = `https://classroom.volp.in/login`
- `VOLP_START_URL` = `https://classroom.volp.in/learner/my-courses`
- `VOLP_USERNAME`
- `VOLP_PASSWORD`
- `TELEGRAM_BOT_TOKEN`
- `TELEGRAM_CHAT_ID`

The workflow runs every 10 minutes and can also be run manually (`workflow_dispatch`).
It also restores/saves `server-bot/state.db` via Actions cache, so notifications stay differential across runs.

## Notes on reliability

- More reliable than extension-only tracking because it does not require your browser popup/manual sync.
- Still depends on valid VOLP login credentials and website structure.
- If VOLP changes UI selectors, update extraction logic in `bot.py`.
