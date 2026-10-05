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
7. SELECT DISTINCT breed FROM cats ORDEto R BY breed;
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

-- ===== DAY 4: joining and aggregating =====
-- ORDER OF EVALUATION with grouping: FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY -> LIMIT

11. SELECT o.full_name, COUNT(c.id) AS cat_count FROM owners o LEFT JOIN cats c ON c.owner_id = o.id GROUP BY o.id, o.full_name ORDER BY cat_count DESC;
-- 11: GROUP BY = one pile per owner, COUNT squashes each pile to a number.
--     COUNT(c.id) not COUNT(*): owner with no cats has 1 row with c.id = NULL -> COUNT(*) = 1 (wrong), COUNT(c.id) = 0.
--     Every plain column in SELECT must be in GROUP BY. Group by o.id, names can repeat.

12. SELECT o.full_name, COUNT(c.id) AS cat_count FROM owners o JOIN cats c ON c.owner_id = o.id GROUP BY o.id, o.full_name HAVING COUNT(c.id) > 2;
-- 12: WHERE filters rows BEFORE grouping, HAVING filters groups AFTER. WHERE COUNT(...) fails - piles don't exist yet.

13. SELECT date_trunc('month', visit_date)::date AS month, COUNT(*) AS visits FROM visits WHERE visit_date >= CURRENT_DATE - INTERVAL '12 months' GROUP BY month ORDER BY month;
-- 13: date_trunc('month', x) rounds down to the 1st of the month -> all March visits get the same value -> one pile.
--     ::date = cast, drops the 00:00:00+02 part.

14. SELECT breed, COUNT(*) AS cats, ROUND(AVG(weight_kg), 2) AS avg_weight, MIN(weight_kg) AS lightest, MAX(weight_kg) AS heaviest FROM cats GROUP BY breed ORDER BY avg_weight DESC;
-- 14: aggregates skip NULL -> AVG = average of KNOWN weights. Only COUNT(*) counts every row.

15. SELECT m.name, SUM(vm.duration_days) AS total_days FROM medications m JOIN visit_medications vm ON vm.medication_id = m.id GROUP BY m.id, m.name ORDER BY total_days DESC;
-- 15: SUM = total days of treatment per medication.

16. SELECT c.name FROM cats c WHERE c.id IN (SELECT v.cat_id FROM visits v WHERE v.complaint ILIKE '%szczep%');
-- 16: IN + subquery: inner query runs once, returns a LIST of cat ids.

17. SELECT c.name FROM cats c WHERE EXISTS (SELECT 1 FROM visits v WHERE v.cat_id = c.id AND v.complaint ILIKE '%szczep%');
-- 17: EXISTS = correlated (uses c.id from outside), checked per cat, answers only yes/no. SELECT 1 doesn't matter.
--     NOT IN trap: one NULL in the subquery -> zero rows. For "doesn't have" use NOT EXISTS.

18. WITH visits_per_owner AS (SELECT o.id, o.full_name, COUNT(v.id) AS visits FROM owners o JOIN cats c ON c.owner_id = o.id JOIN visits v ON v.cat_id = c.id GROUP BY o.id, o.full_name) SELECT full_name, visits FROM visits_per_owner WHERE visits > (SELECT AVG(visits) FROM visits_per_owner) ORDER BY visits DESC;
-- 18: CTE = named temporary table for ONE query (like a local variable in Java).
--     Clearer than nesting: reads top-down, written once / used twice, each step can be run on its own.

19. SELECT o.full_name, COUNT(c.id) AS cat_count, string_agg(c.name, ', ' ORDER BY c.name) AS cats FROM owners o LEFT JOIN cats c ON c.owner_id = o.id GROUP BY o.id, o.full_name;
-- 19: string_agg(value, separator) = aggregate like COUNT, but squashes the pile into ONE string.
--     ORDER BY goes INSIDE the parentheses. No cats -> NULL (not ''), COALESCE(string_agg(...), '-') if needed.

20. SELECT v.id, v.visit_date, c.name, string_agg(m.name || ' (' || vm.dosage || ')', '; ') AS medications FROM visits v JOIN cats c ON c.id = v.cat_id JOIN visit_medications vm ON vm.visit_id = v.id JOIN medications m ON m.id = vm.medication_id GROUP BY v.id, v.visit_date, c.name ORDER BY v.visit_date DESC;
-- 20: many-to-many in one row per visit instead of one row per medication. || = string concatenation (like + on Strings in Java).

21. SELECT o.full_name, string_agg(DISTINCT c.breed, ', ') AS breeds FROM owners o JOIN cats c ON c.owner_id = o.id GROUP BY o.id, o.full_name;
-- 21: DISTINCT inside string_agg -> no 'perski, perski'.
--     string_agg = for humans reading reports. For Java code use normal rows or array_agg.
