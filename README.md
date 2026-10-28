# Where Should We Eat? · Fort Worth

A random restaurant picker for Fort Worth, with a "Been There" tracker for check-offs, star ratings, and notes.

## Files
- `index.html`: the page structure
- `style.css`: the look
- `script.js`: the logic (picker, filters, ratings, notes)
- `restaurants.js`: **the restaurant list, which is the only file you need to edit**

## Run it locally
Double-click `index.html` to open it in your browser.

## Put it on GitHub
1. Go to github.com, click **New repository**, name it `fw-restaurant-picker`, and choose Public.
2. Click **uploading an existing file**, drag in all 5 files, then click **Commit changes**.

## Make it a live website with Netlify
1. Go to netlify.com and log in with GitHub.
2. Click **Add new site**, then **Import an existing project**, then **GitHub**, and pick `fw-restaurant-picker`.
3. Leave the build settings blank and click **Deploy**.
4. Under **Site configuration**, then **Change site name**, pick something like `gracie-eats-fw`.

From then on, every change you commit to GitHub redeploys the site automatically.

## Adding or editing restaurants
Open `restaurants.js` and copy any line. Change the name, category, price (1–4), and add `website: "https://..."` or `menu: "https://..."` if you want those buttons to show.

## About saved notes
Check-offs, ratings, and notes are saved in the browser you use. That means each device keeps its own, and other visitors can't see or change yours. Use **Export backup** and **Import backup** to move them between your phone and laptop.
