# StudyBuddy — Full deployment starter

This project is a deployable starter for a public-link StudyBuddy website. Anyone can open the website URL; each student signs up/logs in to access their own private notes. It uses Supabase Auth, Postgres, private Storage and a Netlify serverless function that calls the OpenAI API.

## What is included

- `index.html` — responsive UI, login/signup, profile, notes library, PDF viewer/download, AI study chat.
- `config.js` — public Supabase URL and publishable/anon key placeholders.
- `schema.sql` — profiles/notes tables, row-level security policies and private storage bucket policies.
- `netlify/functions/study-ai.mjs` — server-side AI function; checks the logged-in user's Supabase access token before calling OpenAI.
- `netlify.toml`, `package.json` — Netlify deployment settings and function dependencies.

## Step 1 — Create Supabase project

1. Go to https://supabase.com and create a project. Save the database password somewhere safe.
2. In the project dashboard, open **SQL Editor → New query**.
3. Paste all of `schema.sql` and click **Run**. Confirm it completes successfully.
4. Open **Project Settings → API** (or **Data API / API Keys**, depending on the dashboard layout). Copy the Project URL and the publishable key (or legacy anon public key). Do **not** use the `service_role` / secret key in the browser.
5. Edit `config.js` and replace `YOUR_SUPABASE_PROJECT_URL` and `YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY` with those values.
6. In **Authentication → URL Configuration**, after deploying, set the Site URL to your Netlify URL. Add that URL to Redirect URLs too. For local testing, add `http://localhost:8888/**`.
7. For a first smoke test, you can disable email confirmation under **Authentication → Providers → Email**; for a public production site, keep confirmation enabled and configure SMTP/email delivery.

## Step 2 — Create AI API key

1. Create an API key at https://platform.openai.com/api-keys.
2. API usage may incur charges; set usage limits/budget alerts in the provider dashboard.
3. Never paste this key into `config.js`, `index.html`, GitHub, or any browser-visible file.

## Step 3 — Deploy on Netlify

Recommended: use a private GitHub repository so you can update the app later.

1. Create a GitHub repository and upload the contents of this folder (all files and the `netlify` folder).
2. In https://app.netlify.com, choose **Add new site → Import an existing project**, connect GitHub, and select the repository.
3. Build settings: publish directory `.`; functions directory is configured in `netlify.toml`. No build command is needed.
4. In Netlify **Project configuration → Environment variables**, add these variables (Functions scope enabled):
   - `OPENAI_API_KEY` = your secret OpenAI API key
   - `SUPABASE_URL` = your Supabase Project URL
   - `SUPABASE_ANON_KEY` = the Supabase publishable/anon key (not service_role)
   - Optional `OPENAI_MODEL` = `gpt-4.1-mini`
5. Deploy the site. If you change environment variables later, trigger a new deploy so functions use the updated values.
6. Copy your Netlify URL (for example `https://your-site-name.netlify.app`) and add it to Supabase Auth **Site URL** and **Redirect URLs**.
7. Redeploy after editing `config.js` or changing environment variables.

A manual Netlify Drop deploy of only static files is not sufficient for the AI function. Use a connected Git repository or Netlify CLI so the `netlify/functions` code is deployed and dependencies are bundled.

## Step 4 — Test end-to-end

1. Open the Netlify URL in a private/incognito browser window.
2. Sign up with an email and password (minimum 8 characters). Confirm email if enabled.
3. Log in; fill out your profile if needed.
4. Upload a small text-based PDF or paste text into a note. Open it from **My Notes**; PDFs use a private, short-lived signed URL.
5. In **AI Study Buddy**, select the note and ask for a summary or a quiz.
6. Create a second test account and confirm its notes list is separate. Never test access to another user's private files with real sensitive material.

## Important limitations and security notes

- The public website URL is open to anyone, but note content/files are private per account due to Supabase Row Level Security and private Storage policies. Do not make the storage bucket public.
- The browser extracts selectable text from text-based PDFs (up to 50 pages) so the AI can work with it. Scanned image-only PDFs and handwritten images need OCR, which is not included in this starter. AI requests use up to 30,000 characters of note text.
- OpenAI usage may cost money. Consider rate limiting, per-user quotas, abuse monitoring and a privacy policy before public launch.
- This is a functional starter, not a completed audited production service. Before sharing widely, configure email/SMTP, backups, monitoring, privacy/terms, request limits, and test Supabase RLS policies. Do not store real sensitive student data until your institution approves the privacy and security setup.
- Keep the Supabase service-role key secret. It is not required by this project.

## Local testing (optional)

Install Node.js, then run from this folder:

```bash
npm install
npx netlify dev
```

Netlify CLI serves the site and the function at `http://localhost:8888`. You still need to set the same environment variables locally (for example in an untracked `.env` file supported by Netlify CLI); never commit `.env`.
