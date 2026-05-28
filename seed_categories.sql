-- Finance App — Category Migration + Seed
-- Run this in the Supabase SQL Editor
-- Safe to re-run: uses ADD COLUMN IF NOT EXISTS and deletes before inserting

BEGIN;

-- 1. Add parent_id column (no-op if already exists)
ALTER TABLE categories
  ADD COLUMN IF NOT EXISTS parent_id uuid REFERENCES categories(id) ON DELETE SET NULL;

-- 2. Wipe all existing categories
--    Transactions that reference deleted categories will have category_id set to NULL
DELETE FROM categories;

-- 3. Income parents
INSERT INTO categories (name, icon, color, type, parent_id) VALUES
  ('Paycheck',      '💼', '#4ade80', 'income',  NULL),
  ('Canal Tu Jura', '🎬', '#a78bfa', 'income',  NULL);

-- 4. Expense parents
INSERT INTO categories (name, icon, color, type, parent_id) VALUES
  ('Food',          '🍔', '#f97316', 'expense', NULL),
  ('Auto',          '🚗', '#3b82f6', 'expense', NULL),
  ('Bills',         '🏠', '#ef4444', 'expense', NULL),
  ('Subscriptions', '📱', '#8b5cf6', 'expense', NULL),
  ('General',       '📦', '#6b7280', 'expense', NULL),
  ('Travel',        '✈️', '#06b6d4', 'expense', NULL),
  ('Entertainment', '🎮', '#ec4899', 'expense', NULL),
  ('Shopping',      '🛍️', '#f59e0b', 'expense', NULL);

-- 5. Children — resolved by parent name via CTE
WITH p AS (SELECT id, name FROM categories WHERE parent_id IS NULL)
INSERT INTO categories (name, icon, color, type, parent_id)
SELECT c.name, c.icon, NULL, c.type, p.id
FROM p
JOIN (VALUES
  -- Paycheck
  ('Flextronics',        '🏭', 'income', 'Paycheck'),
  ('Amazon Flex',        '📦', 'income', 'Paycheck'),
  ('McDonalds',          '🍟', 'income', 'Paycheck'),
  -- Canal Tu Jura
  ('Youtube',            '▶️',  'income', 'Canal Tu Jura'),
  ('Nomad',              '💳', 'income', 'Canal Tu Jura'),
  ('BDV Referral',       '🔗', 'income', 'Canal Tu Jura'),
  ('Instagram',          '📸', 'income', 'Canal Tu Jura'),
  -- Food
  ('Dining',             '🍽️', 'expense', 'Food'),
  ('Take Out',           '🥡', 'expense', 'Food'),
  ('Grocery',            '🛒', 'expense', 'Food'),
  ('Flex',               '🍱', 'expense', 'Food'),
  ('Other',              '🍴', 'expense', 'Food'),
  -- Auto
  ('Gas',                '⛽', 'expense', 'Auto'),
  ('Maintenance',        '🔧', 'expense', 'Auto'),
  ('Car Wash',           '🫧', 'expense', 'Auto'),
  ('Tires',              '🛞', 'expense', 'Auto'),
  ('Parking Lot',        '🅿️', 'expense', 'Auto'),
  -- Bills
  ('Rent',               '🏡', 'expense', 'Bills'),
  ('Energy',             '⚡', 'expense', 'Bills'),
  ('Home Insurance',     '🛡️', 'expense', 'Bills'),
  ('Auto Insurance',     '🚘', 'expense', 'Bills'),
  ('Auto Loan',          '💰', 'expense', 'Bills'),
  ('Psicóloga',          '🧠', 'expense', 'Bills'),
  ('Verizon Group',      '📶', 'expense', 'Bills'),
  -- Subscriptions
  ('AppleCare One',      '🍎', 'expense', 'Subscriptions'),
  ('AppleCare One [Gi]', '🍎', 'expense', 'Subscriptions'),
  ('iCloud+',            '☁️', 'expense', 'Subscriptions'),
  ('Youtube Premium',    '▶️',  'expense', 'Subscriptions'),
  ('Photoshop',          '🎨', 'expense', 'Subscriptions'),
  ('Epidemic Sound',     '🎵', 'expense', 'Subscriptions'),
  ('Netflix BR',         '🎬', 'expense', 'Subscriptions'),
  ('Amazon Prime',       '📦', 'expense', 'Subscriptions'),
  ('Claude',             '🤖', 'expense', 'Subscriptions'),
  ('Insta Tu Jura',      '📸', 'expense', 'Subscriptions'),
  ('Apple TV',           '📺', 'expense', 'Subscriptions'),
  -- General
  ('DMV',                '🏛️', 'expense', 'General'),
  ('Move in/out',        '🚚', 'expense', 'General'),
  ('Docs',               '📄', 'expense', 'General'),
  ('Não tem Category',   '❓', 'expense', 'General'),
  -- Travel
  ('Hotel',              '🏨', 'expense', 'Travel'),
  ('Flights',            '✈️', 'expense', 'Travel'),
  -- Entertainment
  ('PSN',                '🎮', 'expense', 'Entertainment'),
  ('Games',              '🕹️', 'expense', 'Entertainment'),
  ('Rolê',               '🎉', 'expense', 'Entertainment'),
  -- Shopping
  ('Amazon',             '📦', 'expense', 'Shopping'),
  ('Beauty/Health',      '💄', 'expense', 'Shopping'),
  ('Camping',            '⛺', 'expense', 'Shopping'),
  ('Clothes',            '👕', 'expense', 'Shopping'),
  ('Furniture',          '🛋️', 'expense', 'Shopping'),
  ('Art',                '🎨', 'expense', 'Shopping'),
  ('Other',              '🛍️', 'expense', 'Shopping'),
  ('Gift',               '🎁', 'expense', 'Shopping'),
  ('Apple',              '🍎', 'expense', 'Shopping')
) AS c(name, icon, type, parent_name) ON p.name = c.parent_name;

COMMIT;

-- Verify:
-- SELECT count(*), CASE WHEN parent_id IS NULL THEN 'parent' ELSE 'child' END AS level
-- FROM categories GROUP BY level;
-- Expected: 10 parents, 52 children
