# ChargeScout — start here

This is the complete project. Everything you need is in this folder.

## What's in here
- `chargescout.html` — the app itself (already has your real Supabase keys in it)
- `manifest.json`, `service-worker.js`, `icon-*.png` — make it installable as a PWA
- `supabase-schema.sql` — run this once in Supabase's SQL Editor (if you haven't already)
- `.github/workflows/deploy.yml` — auto-deploys to GitHub Pages on every push
- `.gitignore` — keeps Mac's `.DS_Store` file out of your repo

## One-time setup, top to bottom

### 1. Open this whole folder in VS Code
File → Open Folder → select this folder (not just one file inside it).

### 2. Confirm Supabase is ready
In your Supabase project:
- SQL Editor → confirm `supabase-schema.sql` has already been run (it has,
  if reports/stations are showing up when you test)
- Authentication → Providers → Anonymous → confirm it's **enabled**

### 3. Push to GitHub
In VS Code:
- Source Control icon → **Initialize Repository** (only if this folder isn't
  already a git repo)
- Stage all files, write a commit message, click the checkmark to commit
- Open a terminal (Terminal → New Terminal) and run:
  ```bash
  git branch -M main
  git remote add origin https://github.com/YOUR_USERNAME/app.git
  git push -u origin main
  ```
  (Use your actual GitHub username and repo name — copy the exact URL from
  the green "Code" button on your repo's GitHub page.)

### 4. Turn on GitHub Pages
On GitHub.com, your repo → **Settings → Pages** → under **Source**, choose
**GitHub Actions** (not a suggested template like Next.js/Jekyll — you
already have your own workflow).

### 5. Confirm it deployed
Repo → **Actions** tab → wait for a green checkmark on "Deploy ChargeScout
to GitHub Pages." Then **Settings → Pages** shows your live URL at the top.

### 6. Test it live
Open that URL. Post a test report, refresh the page — if it's still there,
you're fully connected. If not, open the browser console (right-click →
Inspect → Console) and check the error message.

### 7. Install it
- Phone: open the live URL → Share/⋮ menu → **Add to Home Screen**
- Desktop (Chrome/Edge): click the install icon in the address bar

## From now on
Every `git push` to `main` auto-redeploys the site within a minute or two.
Make your edits in VS Code, commit, push — that's the whole loop.
