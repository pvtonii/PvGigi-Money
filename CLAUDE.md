# Finance — CLAUDE.md

Context for Claude Code on this project.

## What this project is

A personal finance tracker PWA for two users: **PV** and **Gigi**. The entire app lives in a single `index.html` file — no build tools, no frameworks, no npm. The Supabase JS client is loaded via CDN.

## Architecture

- **Single file app**: all HTML, CSS, and JS is in `index.html` (~7000+ lines). When editing, use offset/limit to read specific sections rather than loading the whole file.
- **Supabase backend**: all data lives in Supabase. The connection credentials (URL + anon key) are stored in `localStorage` under the key `finance_supabase_conn`.
- **PWA**: `manifest.json` + `icons/` folder. `sw.js` is a self-destruct service worker that removes the previous SW — it is not a caching SW.
- **No build step**: edits to `index.html` are live immediately.

## Key JS objects (in index.html)

| Object | Role |
|---|---|
| `State` | In-memory store for all loaded data (categories, accounts, cards, transactions, subscriptions) |
| `Data` | All Supabase CRUD operations |
| `Auth` | PIN login, session management via `localStorage` |
| `App` | UI rendering, navigation, formatters |
| `Connection` | Saves/loads Supabase credentials from localStorage |
| `Status` | Updates the connection status dot in the header |
| `ActivityLog` | Records and renders the last 15 actions |

## Navigation structure

- Bottom nav: Dashboard · Transactions · Cards · Calendar · More (→ Settings / Insights)
- Pages use `id="page-*"` and toggle `.active` class
- Settings page has tabs: Categories, Accounts, Cards, Recurring, History, Connection

## Users

Two hardcoded users: `pv` and `gigi`. User avatars use CSS classes `.pv` and `.gigi`. Login is PIN-based (4 digits). Fallback user data is defined in `FALLBACK_USERS` in case Supabase is unreachable.

## Transactions

- Types: `income`, `expense`
- Flags: `is_transfer`, `is_payment`, `external_to`
- Installments: `installments_total`, `installment_number` — batch-inserted via `createTransactionsBatch`
- Transfers: creates two linked rows with a shared `transfer_group_id`

## Supabase tables

`users`, `categories`, `accounts`, `cards`, `transactions`, `subscriptions`, `activity_log`

## Icons

Source image: `IMG_6582.PNG` (1024×1024). All icons in `icons/` are resized from this file using `sips`. If icons need to be regenerated:

```bash
sips -z 192 192 IMG_6582.PNG --out icons/icon-192.png
sips -z 512 512 IMG_6582.PNG --out icons/icon-512.png
sips -z 180 180 IMG_6582.PNG --out icons/icon-180.png
sips -z 192 192 IMG_6582.PNG --out icons/icon-192-maskable.png
sips -z 512 512 IMG_6582.PNG --out icons/icon-512-maskable.png
```

## Things to be careful about

- `index.html` is large — always read only the relevant section (use offset + limit).
- The Supabase anon key is public by design (it's a client-side app), but never hardcode credentials in the file — users enter them via Settings.
- Do not add a real service worker with caching; the current `sw.js` intentionally removes any SW.
- Currency formatting is handled by `App.formatCurrency()` — don't format amounts manually.
