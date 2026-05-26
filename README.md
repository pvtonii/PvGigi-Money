# Finance — PV & Gigi

Personal and shared finance tracker built as a PWA (Progressive Web App).

## What it does

- Track income and expenses for two users (PV and Gigi) with a shared view
- Dashboard with today's balance, monthly projections, upcoming bills, and recent activity
- Credit card management with monthly invoice breakdown
- Recurring expenses, subscriptions, and recurring income
- Transfers between accounts
- Installment purchases (parcelamento)
- Calendar view and spending insights
- Activity history synced across all devices

## Tech stack

| Layer | Tech |
|---|---|
| Frontend | Vanilla HTML + CSS + JS (single `index.html`) |
| Backend / DB | [Supabase](https://supabase.com) |
| Auth | PIN-based (4 digits), user records in Supabase |
| Distribution | PWA — installable on iOS and Android |

No build step. No frameworks. No dependencies beyond the Supabase JS client (loaded via CDN).

## Project structure

```
Finance/
├── index.html          # Entire app (HTML + CSS + JS)
├── manifest.json       # PWA manifest
├── sw.js               # Service worker (self-destruct, cleans up old SW)
├── icons/              # App icons in multiple sizes
│   ├── icon-192.png
│   ├── icon-512.png
│   ├── icon-180.png    # Apple touch icon
│   ├── icon-192-maskable.png
│   └── icon-512-maskable.png
└── IMG_6582.PNG        # Source image used for the app icons
```

## Pages

| Page | Description |
|---|---|
| Dashboard | Balance overview, monthly summary, upcoming bills, recent activity |
| Transactions | Full transaction list with search and filters |
| Cards | Credit cards with monthly invoice view |
| Calendar | Transactions by date |
| Insights | Spending breakdown by category |
| Settings | Categories, Accounts, Cards, Recurring items, History, Supabase connection |

## Supabase tables

| Table | Purpose |
|---|---|
| `users` | User records with PIN |
| `categories` | Expense and income categories |
| `accounts` | Bank accounts |
| `cards` | Credit cards |
| `transactions` | All income/expense entries |
| `subscriptions` | Recurring charges (subscriptions, bills, income) |
| `activity_log` | Last 15 actions across all devices |

## Running locally

No build required — just open `index.html` in a browser or serve via any static file server:

```bash
npx serve .
```

On first load, go to **Settings → Connection** and enter your Supabase project URL and anon key.

## Deploying

Push to GitHub. The app is served directly from GitHub Pages (or any static host). No server needed.
