# Bank Customer Churn Analysis

An end-to-end analysis of customer churn drivers for a retail bank, moving from SQL exploratory analysis through Python statistical validation to an interactive Power BI dashboard.

## Problem Statement

Customer churn is one of the costliest problems in retail banking — acquiring a new customer typically costs far more than retaining an existing one. This project investigates which customer attributes actually predict churn, using a bank customer dataset covering demographics, account activity, and product holdings.

The goal wasn't just to find correlations, but to **validate them statistically** and check whether apparent patterns held up once confounding variables were controlled for.

## Methodology

The project followed a three-phase, tool-appropriate workflow:

1. **SQL (PostgreSQL / pgAdmin)** — exploratory data analysis across Geography, Balance, NumOfProducts, Gender, Tenure, CreditScore, HasCrCard, and EstimatedSalary to surface candidate churn drivers
2. **Python (pandas, scipy — Google Colab)** — chi-square tests and Cramér's V effect sizes to formally validate which candidate drivers were statistically significant, and to rule out the ones that weren't
3. **Power BI** — an interactive dashboard (PostgreSQL Import mode, DAX measures validated against the SQL findings) to visualize the validated drivers and let a viewer drill into specific segments

## Key Findings

Ranked by effect size (Cramér's V):

| Variable | Cramér's V | Verdict |
|---|---|---|
| **NumOfProducts** | 0.388 | Strongest predictor — non-linear, near-deterministic at the extremes |
| **Age / Age Risk Band** | 0.352 | Strong — churn peaks sharply at ages 45–60 |
| **Geography** | weak–moderate | Real, but concentrated in specific sub-segments |
| CreditScore | negligible | Ruled out |
| Tenure | negligible | Ruled out |
| EstimatedSalary, HasCrCard | negligible | Ruled out |

### 1. NumOfProducts — a U-shaped risk curve, not a linear one

Churn does **not** decrease as customers hold more products, despite that being the intuitive assumption ("more products = stickier customer"):

| Products Held | % of Customers | Churn Rate |
|---|---|---|
| 1 | 69.2% | 27.7% |
| 2 | 17.1% | **7.6%** (safest segment) |
| 3 | 10.8% | 82.7% |
| 4 | 3.0% | 100%* |

*Based on n=60 — directionally consistent with the tier-3 pattern, but a smaller sample than the other tiers.

Two products is the "sweet spot." Beyond that, churn risk becomes near-universal — a strong signal that 3+ product customers may be over-sold or mis-matched to products they didn't want, rather than genuinely more loyal.

### 2. Age — a peak in the 45–60 pre-retirement window

Churn rises steadily through a customer's 20s–40s, spikes sharply between ages 45 and 60 (peaking at 58% in the 50–55 band), then declines to near-zero past 75. This is a non-linear, "risk window" pattern rather than a simple "older = more likely to churn" relationship.

### 3. Geography — amplifies risk, but only in specific ranges

Germany has a materially higher overall churn rate (~32%) than France or Spain (~16–17%). Testing this against the other two variables revealed the effect is not uniform:

- **Within the 45–60 age band:** Germany churns at 66% vs. ~40–44% for France/Spain — the effect holds even after controlling for age composition (chi-square p<0.001, Cramér's V=0.22 within-band).
- **Within the 1–2 product tiers:** Germany again runs roughly double France/Spain (e.g., 42.8% vs. ~22% at 1 product).
- **At 3+ products:** the effect disappears — churn saturates near 80–100% in every market. NumOfProducts dominates and overrides Geography at the extremes.

**Combined story:** Germany's elevated churn isn't spread evenly — it's concentrated in customers with 1–2 products and in the 45–60 age range. Outside those conditions, market differences shrink or vanish entirely.

## Dashboard

Two-page interactive Power BI dashboard:

- **Page 1 — Overview:** headline churn rate, churner volume by geography, key findings callout
- **Page 2 — Segment Drill-Down:** slicer-driven exploration (Geography, Gender, Active Member, NumOfProducts), NumOfProducts × Geography churn heatmap, Age Risk Band × Geography interaction chart, drillthrough from Page 1's geography chart

*(Add screenshots here — recommended: heatmap, Age×Geography chart, Page 1 overview)*

*(Add link to published Power BI dashboard here, if published)*

## Tools & Stack

- **Database:** PostgreSQL, pgAdmin
- **Statistical validation:** Python (pandas, scipy.stats), Google Colab
- **Visualization:** Power BI, DAX
- **Techniques:** Chi-square tests of independence, Cramér's V effect size, segmented/conditional analysis to test for confounding

## Repository Structure

```
├── sql/                  # EDA queries
├── notebooks/            # Python statistical validation (Colab/Jupyter)
├── dashboard/            # Power BI file (.pbix) and/or exported screenshots
└── README.md
```
