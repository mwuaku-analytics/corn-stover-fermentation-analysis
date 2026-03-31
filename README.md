# 🌽 Corn Stover Fermentation & Digestibility Analysis

**A Data Analytics Portfolio Project | Michael Wuaku**

---

## 📌 Project Overview

This project transforms findings from a peer-reviewed research publication into a structured data analytics workflow, demonstrating proficiency in **SQL database design**, **analytical querying**, and **Power BI dashboard development**.

> **Source Publication:**
> Wuaku, M., Isikhuemhen, O.S., et al. (2025). *Solid state fermentation: A strategy for wheat bran supplemented corn stover valorization with Pleurotus species.* AIMS Microbiology, 11(1): 206–227.
> DOI: [10.3934/microbiol.2025011](https://doi.org/10.3934/microbiol.2025011)

---

## 🎯 Business / Research Questions Answered

1. **Which fungal strain most effectively improved corn stover digestibility?**
2. **At what incubation week does each strain reach peak performance?**
3. **Which treatment produces the most energy-efficient rumen fermentation?**
4. **How does fiber breakdown (cellulose, hemicellulose) change over time?**
5. **Which strain-week combination delivers the best composite fermentation outcome?**

---

## 🗂️ Repository Structure

```
corn-stover-analysis/
│
├── sql/
│   ├── 01_create_schema.sql       # Database schema + data inserts
│   └── 02_analytical_queries.sql  # 7 analytical SQL queries
│
├── data/
│   └── fermentation_digestibility_data.csv  # Power BI-ready flat file
│
├── docs/
│   └── powerbi_dashboard_guide.md  # Step-by-step Power BI setup guide
│
└── README.md
```

---

## 🛠️ Tools & Skills Demonstrated

| Tool | Usage |
|---|---|
| **SQL (SQLite)** | Relational schema design, window functions, CTEs, CASE statements, JOINs, aggregations |
| **Power BI** | Multi-page dashboard, slicers, line charts, bar charts, KPI cards, DAX measures |
| **Data Wrangling** | Extracted and structured raw data from published scientific tables |
| **Domain Knowledge** | Agricultural science, ruminant nutrition, fermentation biology |

---

## 🗃️ Database Design

The SQL database follows a **star schema** with one dimension table and three fact tables:

```
fungal_strains (dimension)
    │
    ├── gas_dm_digestibility    (fact: Table 2 from paper)
    ├── fiber_digestibility     (fact: Table 3 from paper)
    └── volatile_fatty_acids    (fact: Table 4 from paper)
```

**Key variables tracked:**
- **Gas Production** (mL/g DM) — fermentable carbohydrate availability
- **Dry Matter Digestibility** (DMD %) — nutrient utilization efficiency
- **Fiber Fractions** (NDF, ADF, cellulose, hemicellulose digestibility)
- **Volatile Fatty Acids** (acetate, propionate, butyrate ratios)
- **Microbial Mass** (g/kg DM) — rumen microbial efficiency

---

## 📊 SQL Highlights

### Window Functions
```sql
-- Track DMD change week-over-week per strain
SELECT strain_id, incubation_week, dmd_pct,
    LAG(dmd_pct) OVER (PARTITION BY strain_id ORDER BY incubation_week) AS prev_week_dmd,
    ROUND(dmd_pct - LAG(dmd_pct) OVER (PARTITION BY strain_id ORDER BY incubation_week), 2) AS dmd_change
FROM fiber_digestibility;
```

### CTEs + RANK
```sql
-- Find optimal incubation week per strain
WITH ranked AS (
    SELECT strain_id, incubation_week, dmd_pct,
           RANK() OVER (PARTITION BY strain_id ORDER BY dmd_pct DESC) AS rnk
    FROM fiber_digestibility
)
SELECT r.strain_id, fs.species, r.incubation_week AS optimal_week, r.dmd_pct
FROM ranked r
JOIN fungal_strains fs ON r.strain_id = fs.strain_id
WHERE r.rnk = 1;
```

### Composite Scoring
```sql
-- Multi-metric composite performance score
ROUND((g.ivtddm_pct * 0.4) + (fd.dmd_pct * 0.4) + (g.gas_ml_per_g_dm * 0.2), 2) AS composite_score
```

---

## 📈 Power BI Dashboard Pages

| Page | Visuals |
|---|---|
| **Overview** | KPI cards (avg DMD, avg gas production, avg propionate), strain comparison bar chart |
| **Digestibility Trends** | Line chart — DMD over weeks by strain; ADF & cellulose digestibility heatmap |
| **Fermentation Profile** | Clustered bar — acetate vs propionate by strain/week; VFA composition stacked bar |
| **Best Treatment Finder** | Table with composite scores; slicer for strain & week |

---

## 🔑 Key Findings (Data Insights)

- **P. pulmonarius (P2) at Week 6** achieved the highest dry matter digestibility (36.2%) and gas production (92.1 mL/g DM), making it the top performer overall
- **P2 progressively shifted** fermentation from acetate-dominant to propionate-dominant — a more energy-efficient profile for ruminants
- **Wild isolate P3** showed consistently higher microbial mass at Week 8 (0.048 g/kg DM), suggesting superior microbial biomass synthesis
- **Cellulose digestibility** increased linearly with incubation time across all strains, confirming effective lignocellulose breakdown

---

## ▶️ How to Run the SQL

1. Install [SQLite](https://www.sqlite.org/download.html) or use [DB Browser for SQLite](https://sqlitebrowser.org/) (free GUI)
2. Open a new database
3. Run `01_create_schema.sql` to create tables and load data
4. Run `02_analytical_queries.sql` to execute all analyses

---

## 📬 Contact

**Michael Wuaku**
Department of Animal Sciences, North Carolina A&T State University
📧 Connect via [LinkedIn](#) | 🐙 [GitHub](#)

---

*This project is based on open-access research published under the Creative Commons Attribution License (CC BY 4.0).*
## 📊 Dashboard Screenshots

### Overview
![Overview](Screenshot%202026-03-30%20235804.png)

### Digestibility Trends
![Digestibility Trends](Screenshot%202026-03-30%20235928.png)

### VFA Fermentation Profile
![VFA Fermentation Profile](Screenshot%202026-03-30%20235953.png)

### Best Treatment Finder
![Best Treatment Finder](Screenshot%202026-03-30%20000100.png)
