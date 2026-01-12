# Causal Impact & ROI Analysis of a Regional Business Intervention

##  Project Overview

This project evaluates the **causal business impact** of a regional intervention using a **Difference-in-Differences (DiD)** framework. The objective is not just to report changes in sales, but to isolate **incremental impact attributable to the intervention**, adjust for overall market trends, and translate the results into **ROI and decision-ready insights**.

The analysis follows a **production-style analytics workflow**:

* Data preparation and validation
* Causal impact estimation in SQL
* Financial translation (ROI)
* Scenario-based decision analysis
* Executive-ready visualization in Power BI

---

##  Business Question

> Did the intervention in the **West region** generate incremental sales beyond what would have happened due to overall market trends, and was the investment financially justified?

---

##  Methodology

### Treatment & Control

* **Treatment group:** West region
* **Control group:** All other regions

### Intervention

* **Start date:** January 2016

### Method

* **Difference-in-Differences (DiD)**

DiD estimates causal impact by comparing:

* Pre vs post changes in the treatment region
* Against pre vs post changes in control regions

This removes the effect of seasonality and macro trends, isolating the **true intervention effect**.

---

##  Data Preparation

* Raw transactional data was **cleaned and prepared using Python (pandas)**

* Steps included:

  * Parsing and standardizing date fields
  * Selecting relevant analytical columns
  * Aggregating transactional data to **monthly region-level metrics**
  * Validating data completeness and consistency

* The cleaned dataset was then exported and loaded into SQL Server for all downstream causal and financial analysis

A base table was created with explicit flags:

* `is_treatment` → identifies treatment vs control
* `is_post` → identifies pre vs post intervention periods

This ensures all downstream analysis uses a **consistent causal definition**.

---

##  Causal Impact Estimation (SQL)

The causal logic was implemented entirely in **SQL using layered views**, following best practices:

1. **Base flags view** – encodes treatment and intervention periods.
2. **Group averages view** – computes pre/post averages for treatment and control.
3. **DiD view** – calculates the monthly incremental impact.

This approach ensures:

* Transparency.
* Reproducibility.
* Easy reuse across reporting and dashboards.

---

##  Business Impact & ROI

The estimated monthly causal uplift was translated into business value by:

* Multiplying monthly uplift by post-intervention duration.
* Subtracting campaign cost.
* Computing ROI.

 ROI = (Incremental Revenue − Campaign Cost) / Campaign Cost

All assumptions were kept **explicit and auditable**.

---

##  Scenario Analysis

Because campaign cost is uncertain in real-world settings, a **scenario analysis** was performed:

| Scenario  | Campaign Cost |
| --------- | ------------- |
| Low Cost  | ₹7,000        |
| Base Case | ₹10,000       |
| High Cost | ₹15,000       |

This allows stakeholders to understand:

* Downside risk
* Upside potential
* Sensitivity of ROI to cost assumptions

---

##  Power BI Dashboard

The Power BI report is structured into three pages:

1. **Executive Summary**

   * Incremental monthly sales
   * Total incremental revenue
   * ROI
   * Methodology overview

2. **Causal Impact (DiD)**

   * Treatment vs control comparison
   * Pre vs post averages
   * DiD impact transparency

3. **Scenario Analysis**

   * ROI by cost scenario
   * Net benefit comparison
   * Decision-focused visualization

All calculations remain in SQL; Power BI is used strictly for **communication and storytelling**.

---

##  Assumptions & Limitations

* Parallel trends assumption holds approximately, though the treatment region shows higher volatility.
* Campaign cost values are assumed for illustration and scenario testing.
* Results should be interpreted directionally rather than as precise forecasts.

---

##  Key Takeaway

> The intervention in the West region generated incremental revenue after adjusting for market trends, and under realistic cost assumptions, delivered a positive return on investment.

This project demonstrates an **end-to-end causal analytics workflow**, bridging data engineering, econometric reasoning, and business decision-making.

---

##  Tools & Technologies

* **Python (pandas, matplotlib)** – data cleaning, aggregation, and validation.
* **SQL Server (SSMS)** – causal impact estimation, ROI, and scenario analysis using views.
* **Power BI** – executive reporting and decision-focused visualization.

---

##  How to Use

* Review SQL views for full causal and ROI logic.
* Explore the Power BI dashboard for executive insights.
* Adjust campaign cost assumptions to test alternative scenarios.

---




