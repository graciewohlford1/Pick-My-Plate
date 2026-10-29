# Turning on logins for Pick my Plate

The app works without this. Until you add your keys, everyone just uses it
as a guest and their data stays on their own device. These steps turn on
real accounts so each person's passport, ratings and spots follow them to
any device. It's free and takes about 10 minutes.

## 1. Create a free Supabase project
1. Go to **supabase.com** and click **Start your project**. Sign in with GitHub.
2. Click **New project**. Name it `pick-my-plate`, make up a database
   password (save it somewhere), pick the region closest to you (e.g.
   *East US* or *Central US*), and click **Create new project**.
3. Wait a minute or two while it sets up.

## 2. Make the table
1. In the left sidebar, click **SQL Editor**, then **New query**.
2. Open `supabase-setup.sql`, copy everything, paste it in, and click **Run**.
   You should see "Success. No rows returned."

## 2b. Turn on friends
Open a **New query** again, paste everything from `supabase-friends.sql`, and
click **Run**. This adds friend codes and friend requests. It also sets the
rule that only people who've accepted each other as friends can see each
other's stars and notes. Emails are never shared.

## 3. Tell Supabase where your site lives
1. Left sidebar: **Authentication** → **URL Configuration**.
2. Set **Site URL** to `https://graciewohlford1.github.io/Pick-My-Plate/`
3. Under **Redirect URLs**, click **Add URL** and add the same address.
   This makes the "confirm your email" and "reset password" links open your site.

Optional: under **Authentication → Sign In / Providers → Email**, you can turn
off **Confirm email** if you don't want friends to have to click a link
before their first login.

## 4. Copy your two keys into the app
1. Left sidebar: **Project Settings** (gear icon) → **API** (or **Data API**).
2. Copy the **Project URL** and the **anon public** key.
3. Open `index.html` and find these two lines near the top of the script:
   ```js
   const SUPABASE_URL = "";
   const SUPABASE_ANON_KEY = "";
   ```
   Paste your values between the quotes and save.

The anon key is meant to be public. It's safe on GitHub because the table
rules from step 2 only let each person reach their own data. Never paste the
**service_role** key anywhere in the site.

## 5. Upload and test
1. Upload the updated `index.html` to your GitHub repo (replace the old one).
2. Open `https://graciewohlford1.github.io/Pick-My-Plate/` and click
   **Create account**.
3. If you'd already rated places on that device, it will ask to bring them
   over. Say yes.
4. Log in on your phone with the same email to see everything synced.

To see who has signed up: **Authentication → Users** in Supabase.
