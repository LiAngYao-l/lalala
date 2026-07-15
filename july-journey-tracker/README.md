# July Journey Tracker

Personal HTML tracker for **身弱壬水日主** monthly guidance（2026.7.7 – 2026.8.6）and post-travel reset.

## Open

```bash
open july-journey-tracker/index.html
```

Or, for shared `data.json` auto-load:

```bash
cd july-journey-tracker
python3 -m http.server 8765
# then open http://127.0.0.1:8765
```

## Use on home + work computers

Browser checkbox/notes are only local unless you sync **`data.json`**.

### Recommended: iCloud Drive (simplest on two Macs)

1. Put the whole `july-journey-tracker` folder in **iCloud Drive** (or Dropbox).
2. On both Macs, open `index.html` from that synced folder.
3. Tonight at home, after updating your day:
   - Click **Save Shared Data (data.json)**
   - Save/replace `data.json` inside the same synced folder
4. Tomorrow at work:
   - Open the same folder’s `index.html`
   - Click **Load Shared Data** and choose that `data.json`
   - Or in Chrome/Edge: click **Connect data.json (auto-save)** once, then edits write into the file automatically

Wait until iCloud finishes syncing before switching machines.

### Alternative: Git

```bash
# At home after Save Shared Data replaced data.json
git add july-journey-tracker/data.json
git commit -m "Update journey day"
git push

# At work
git pull
open july-journey-tracker/index.html
# Load Shared Data if the page did not auto-load data.json
```

## What’s included

- Location status: Bay Area done → McKinsey in-person done → Ann Arbor
- 樂方流月批文 + actionable checklists
- Daily rhythm: wake **7:30**, morning run, sleep **23:00**
- Capture inbox + multi-computer sync controls
