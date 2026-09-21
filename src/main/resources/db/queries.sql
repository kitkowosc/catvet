1. SELECT name, birth_date FROM cats WHERE birth_date >
  '2020-12-31';
-- 1: 'after 2020' = born 2021 or later (my decision). Comparing a DATE to '2020-12-31' works, Postgres casts the text to date.
2. SELECT name FROM cats WHERE name ILIKE '%mit%'; - ILIKE
-- 2: ILIKE = case-insensitive LIKE. % = any string, _ = one char.
3. SELECT full_name FROM owners WHERE phone IS NULL;
-- 3: NULL is 'unknown', not a value -> `phone = NULL` is never true, use IS NULL.
4. SELECT name, breed, birth_date, weight_kg, created_at FROM cats ORDER BY created_at DESC LIMIT 10;
-- 4: ORDER BY ... DESC = newest first, LIMIT 10 = only the first 10 of that order.
5. SELECT name, weight_kg FROM cats WHERE weight_kg BETWEEN 4 AND 5;
-- 5: x BETWEEN a AND b == a <= x AND x <= b, both ends inclusive.
6. SELECT name, breed FROM cats WHERE breed IN ('perski', 'ragdoll', 'maine coon');
-- 6: x IN (a, b, c) == x = a OR x = b OR x = c. Exact values, no wildcards.
7. SELECT DISTINCT breed FROM cats ORDER BY breed;
-- 7: DISTINCT = each selected row once. ORDER BY defaults to ASC (A->Z).

8. SELECT name, breed FROM cats ORDER BY breed, name;
-- 8: multi-column ORDER BY = sort by breed, then by name as tie-breaker within the same breed.

9. SELECT name FROM cats ORDER BY created_at DESC OFFSET 10 LIMIT 10;
-- 9: pagination = OFFSET (skip 10) + LIMIT (show 10) -> rows 11-20. Needs ORDER BY, otherwise pages can overlap.

10. SELECT name, birth_date, EXTRACT(YEAR FROM AGE(birth_date)) AS age_years, CASE WHEN EXTRACT(YEAR FROM AGE(birth_date)) >= 10 THEN 'senior' WHEN EXTRACT(YEAR FROM AGE(birth_date)) >= 2 THEN 'adult' ELSE 'kitten' END AS age_group FROM cats ORDER BY age_years DESC;
-- 10: AGE() returns an interval ('7 years 5 mons'), EXTRACT(YEAR FROM ...) takes one field as a number (truncates).
--     CASE is a computed column -> lives in SELECT. WHENs checked top-down, first match wins.
--     Alias age_years works in ORDER BY (runs after SELECT) but not in WHERE/CASE (run before) -> expression repeated.

-- ORDER OF EVALUATION: FROM -> WHERE -> SELECT -> DISTINCT -> ORDER BY -> LIMIT  (not the order you write it).
