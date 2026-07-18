# ChargeScout

ChargeScout is a mobile-first EV charging discovery app with community reports, live pricing signals, and PWA installability.

## Deploy to GitHub Pages

1. Push this folder to GitHub in a repository named whatever you want.
2. Make sure the default branch is `main`.
3. In GitHub, go to `Settings -> Pages` and choose `GitHub Actions` as the source.
4. Wait for the workflow to finish under `Actions -> Deploy ChargeScout to GitHub Pages`.
5. Open the published URL shown in the Pages settings.

The app is already configured for static hosting and includes:
- a root `index.html` landing redirect
- a PWA manifest
- a service worker for installability
- a GitHub Pages workflow at `.github/workflows/deploy.yml`

## Deploy to Vercel (optional)

If you want to use Vercel instead, the project already includes `vercel.json`.

## Supabase

The app already uses the embedded Supabase URL and anonymous key in the main HTML file. If you want to use your own Supabase project, replace those values at the top of [chargescout.html](chargescout.html).
