# 📊 Power BI Dashboard Guide
## Corn Stover Fermentation & Digestibility Analysis

---

## Step 1: Load the Data

1. Open **Power BI Desktop**
2. Click **Home → Get Data → Text/CSV**
3. Select `fermentation_digestibility_data.csv`
4. Click **Transform Data** to open Power Query Editor
5. Verify all columns are correctly typed:
   - `strain_id`, `species`, `isolate_type` → **Text**
   - `incubation_week` → **Whole Number**
   - All other columns → **Decimal Number**
6. Click **Close & Apply**

---

## Step 2: Create DAX Measures

In the **Data** pane, right-click your table → **New Measure** and add these:

```dax
-- Average Dry Matter Digestibility
Avg DMD % = AVERAGE('fermentation_digestibility_data'[dmd_pct])

-- Average Gas Production
Avg Gas Production = AVERAGE('fermentation_digestibility_data'[gas_ml_per_g_dm])

-- Average Propionate (energy efficiency indicator)
Avg Propionate % = AVERAGE('fermentation_digestibility_data'[propionate_c3_pct])

-- Best DMD value in current filter context
Peak DMD = MAX('fermentation_digestibility_data'[dmd_pct])

-- Acetate to Propionate Ratio (lower = more energy efficient)
Avg C2:C3 Ratio = AVERAGE('fermentation_digestibility_data'[acetate_propionate_ratio])

-- Composite Performance Score
Composite Score =
    AVERAGE('fermentation_digestibility_data'[ivtddm_pct]) * 0.4 +
    AVERAGE('fermentation_digestibility_data'[dmd_pct]) * 0.4 +
    AVERAGE('fermentation_digestibility_data'[gas_ml_per_g_dm]) * 0.2
```

---

## Step 3: Build Dashboard Pages

### Page 1 — Executive Overview
| Visual | Fields |
|---|---|
| KPI Card | `Avg DMD %` |
| KPI Card | `Avg Gas Production` |
| KPI Card | `Avg Propionate %` |
| Clustered Bar Chart | X-axis: `strain_id`, Y-axis: `Avg DMD %`, Legend: `species` |
| Slicer | `incubation_week` |

**Insight title to add:** *"P. pulmonarius (P2) consistently outperformed other strains in digestibility"*

---

### Page 2 — Digestibility Trends Over Time
| Visual | Fields |
|---|---|
| Line Chart | X-axis: `incubation_week`, Y-axis: `dmd_pct`, Legend: `strain_id` |
| Line Chart | X-axis: `incubation_week`, Y-axis: `celd_pct`, Legend: `strain_id` |
| Line Chart | X-axis: `incubation_week`, Y-axis: `adfd_pct`, Legend: `strain_id` |
| Slicer | `strain_id` |

**Tip:** Add a trend line to the DMD line chart (Analytics pane → Trend line)

---

### Page 3 — VFA Fermentation Profile
| Visual | Fields |
|---|---|
| Clustered Bar | X-axis: `strain_id`, Y-axis: `Avg Propionate %` + `Avg DMD %` |
| Stacked Bar | X-axis: `incubation_week`, Values: `acetate_c2_pct` + `propionate_c3_pct` + `butyrate_c4_pct`, Legend: `strain_id` |
| Line Chart | X-axis: `incubation_week`, Y-axis: `total_vfa_mmol`, Legend: `strain_id` |
| Card | `Avg C2:C3 Ratio` |

**Insight to highlight:** *"P2 at Week 6 showed the highest propionate (22.2%) — indicating more efficient energy use for ruminants"*

---

### Page 4 — Best Treatment Finder
| Visual | Fields |
|---|---|
| Table | `strain_id`, `species`, `incubation_week`, `dmd_pct`, `ivtddm_pct`, `gas_ml_per_g_dm`, `Composite Score` |
| Slicer | `strain_id` (multi-select) |
| Slicer | `incubation_week` |
| KPI Card | `Peak DMD` |
| KPI Card | `Composite Score` |

**Sort the table** by `Composite Score` descending to highlight best treatments.

---

## Step 4: Formatting Tips for a Portfolio Dashboard

- **Color theme:** Use a green/earth tone palette to reflect the agricultural theme
  - Primary: `#2E7D32` (dark green)
  - Secondary: `#81C784` (light green)
  - Accent: `#F9A825` (amber)
- Add your **name and publication reference** in the footer of each page
- Add **text boxes** with 1–2 sentence insights on each page
- Use **bookmarks** to create a guided tour for viewers

---

## Step 5: Publish to Power BI Service (Optional)

1. Click **File → Publish → Publish to Power BI**
2. Sign in with a free Power BI account
3. Share the dashboard link on your **GitHub README** and **LinkedIn profile**

---

*Data source: Wuaku et al. (2025), AIMS Microbiology. DOI: 10.3934/microbiol.2025011*
