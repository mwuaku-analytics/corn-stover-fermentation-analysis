-- ============================================================
-- ANALYTICAL SQL QUERIES
-- Project: Corn Stover Digestibility & Fermentation Analysis
-- Author: Michael Wuaku
-- ============================================================


-- ----------------------------------------------------------------
-- QUERY 1: Rank strains by average dry matter digestibility (DMD)
-- Business Question: Which fungal strain most effectively
-- improved corn stover digestibility overall?
-- ----------------------------------------------------------------
SELECT
    fs.strain_id,
    fs.species,
    fs.isolate_type,
    ROUND(AVG(fd.dmd_pct), 2)              AS avg_dmd_pct,
    ROUND(MAX(fd.dmd_pct), 2)              AS max_dmd_pct,
    ROUND(MIN(fd.dmd_pct), 2)              AS min_dmd_pct,
    RANK() OVER (ORDER BY AVG(fd.dmd_pct) DESC) AS dmd_rank
FROM fiber_digestibility fd
JOIN fungal_strains fs ON fd.strain_id = fs.strain_id
GROUP BY fs.strain_id, fs.species, fs.isolate_type
ORDER BY dmd_rank;


-- ----------------------------------------------------------------
-- QUERY 2: Track DMD improvement over incubation time per strain
-- Business Question: At what week does each strain peak in DMD?
-- ----------------------------------------------------------------
SELECT
    strain_id,
    incubation_week,
    dmd_pct,
    LAG(dmd_pct) OVER (PARTITION BY strain_id ORDER BY incubation_week) AS prev_week_dmd,
    ROUND(
        dmd_pct - LAG(dmd_pct) OVER (PARTITION BY strain_id ORDER BY incubation_week),
    2) AS dmd_change
FROM fiber_digestibility
ORDER BY strain_id, incubation_week;


-- ----------------------------------------------------------------
-- QUERY 3: Find the best strain-week combination for gas production
-- and digestibility together (composite performance score)
-- Business Question: Which treatment gives the best overall
-- fermentation performance?
-- ----------------------------------------------------------------
SELECT
    g.strain_id,
    g.incubation_week,
    g.gas_ml_per_g_dm,
    g.ivtddm_pct,
    g.microbial_mass_g_per_kg_dm,
    fd.dmd_pct,
    ROUND(
        (g.ivtddm_pct * 0.4) +
        (fd.dmd_pct   * 0.4) +
        (g.gas_ml_per_g_dm * 0.2),
    2) AS composite_score
FROM gas_dm_digestibility g
JOIN fiber_digestibility fd
    ON g.strain_id = g.strain_id AND g.incubation_week = fd.incubation_week
    AND g.strain_id = fd.strain_id
ORDER BY composite_score DESC
LIMIT 5;


-- ----------------------------------------------------------------
-- QUERY 4: VFA fermentation profile — Acetate vs Propionate shift
-- Business Question: Which strain promotes a more energy-efficient
-- rumen fermentation (higher propionate = better energy for animal)?
-- ----------------------------------------------------------------
SELECT
    v.strain_id,
    fs.species,
    v.incubation_week,
    v.acetate_c2_pct,
    v.propionate_c3_pct,
    v.acetate_propionate_ratio,
    CASE
        WHEN v.propionate_c3_pct >= 21 THEN 'High Propionate (Efficient)'
        WHEN v.propionate_c3_pct BETWEEN 18 AND 21 THEN 'Moderate'
        ELSE 'Low Propionate'
    END AS fermentation_efficiency
FROM volatile_fatty_acids v
JOIN fungal_strains fs ON v.strain_id = fs.strain_id
ORDER BY v.propionate_c3_pct DESC;


-- ----------------------------------------------------------------
-- QUERY 5: Fiber breakdown effectiveness
-- Business Question: Which strain best reduces fiber (NDF/ADF)
-- and breaks down cellulose over time?
-- ----------------------------------------------------------------
SELECT
    fd.strain_id,
    fd.incubation_week,
    fd.adfd_pct,
    fd.celd_pct,
    fd.hemd_pct,
    fd.adld_pct,
    ROUND((fd.adfd_pct + fd.celd_pct) / 2, 2) AS avg_structural_digestibility
FROM fiber_digestibility fd
ORDER BY avg_structural_digestibility DESC;


-- ----------------------------------------------------------------
-- QUERY 6: Identify the optimal incubation week per strain
-- (week where DMD is at its highest)
-- ----------------------------------------------------------------
WITH ranked AS (
    SELECT
        strain_id,
        incubation_week,
        dmd_pct,
        RANK() OVER (PARTITION BY strain_id ORDER BY dmd_pct DESC) AS rnk
    FROM fiber_digestibility
)
SELECT
    r.strain_id,
    fs.species,
    r.incubation_week AS optimal_week,
    r.dmd_pct         AS peak_dmd_pct
FROM ranked r
JOIN fungal_strains fs ON r.strain_id = fs.strain_id
WHERE r.rnk = 1
ORDER BY r.dmd_pct DESC;


-- ----------------------------------------------------------------
-- QUERY 7: Summary statistics — Full fermentation profile by strain
-- ----------------------------------------------------------------
SELECT
    g.strain_id,
    ROUND(AVG(g.gas_ml_per_g_dm), 2)             AS avg_gas_production,
    ROUND(AVG(g.ivaddm_pct), 2)                  AS avg_ivaddm,
    ROUND(AVG(g.ivtddm_pct), 2)                  AS avg_ivtddm,
    ROUND(AVG(g.undegraded_residuals_pct), 2)     AS avg_undegraded,
    ROUND(AVG(fd.dmd_pct), 2)                     AS avg_dmd,
    ROUND(AVG(fd.celd_pct), 2)                    AS avg_cellulose_digestibility,
    ROUND(AVG(v.propionate_c3_pct), 2)            AS avg_propionate,
    ROUND(AVG(v.total_vfa_mmol), 2)               AS avg_total_vfa
FROM gas_dm_digestibility g
JOIN fiber_digestibility fd
    ON g.strain_id = fd.strain_id AND g.incubation_week = fd.incubation_week
JOIN volatile_fatty_acids v
    ON g.strain_id = v.strain_id AND g.incubation_week = v.incubation_week
GROUP BY g.strain_id
ORDER BY avg_dmd DESC;
