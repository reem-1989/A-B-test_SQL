# Landing Page A/B Test (SQL)

Did a new sign-up page get more people to start a free trial? A simple A/B test analysed from start to finish with MySQL.

**Tools:** MySQL · SQL (aggregation, CASE, subqueries) · basic statistics (z-test, confidence interval) · Python (data generation)

---

## The business question

**FreshBox**, a fictional meal-kit company, wanted more visitors to start a free trial. The marketing team wrote a new headline for the sign-up page:

| | Page | Headline |
|---|---|---|
| **A** (control) | Current page | "Start your free trial" |
| **B** (new) | New page | "Get 3 free meals this week" |

For two weeks (3–16 March 2025), every new visitor was **randomly** shown page A or page B. Random assignment means the only real difference between the two groups is the page they saw.

**Metric:** sign-up rate = visitors who started a free trial ÷ all visitors

**Decision rule (set before looking at the results):** switch to page B only if its sign-up rate is higher **and** the difference is statistically significant at the 95% level.

> **About the data:** The dataset is synthetic (10,000 visitors). It was generated with a Python script (`scripts/generate_data.py`) to mirror a real website test. The seed is fixed, so anyone can recreate the exact same data.

---

## The data

One table, one row per visitor:

| Column | Description |
|---|---|
| `visitor_id` | Unique visitor ID |
| `test_group` | `A` (current page) or `B` (new page) |
| `device` | `Mobile` or `Desktop` |
| `visit_date` | Day of the visit |
| `signed_up` | `1` if the visitor started a free trial, else `0` |

---

## Results

### Step 1: check the test is fair (Q2)

| Group | Visitors | Share |
|---|---:|---:|
| A | 5,030 | 50.3% |
| B | 4,970 | 49.7% |

The split is close to 50/50, so the random assignment worked.

### Step 2: compare sign-up rates (Q3)
<img width="600" height="500" alt="image" src="https://github.com/user-attachments/assets/a7c05fa3-ce4f-49a8-b2a4-ec7621629eb6" />


| Group | Visitors | Sign-ups | Sign-up rate |
|---|---:|---:|---:|
| A (current page) | 5,030 | 528 | 10.50% |
| B (new page) | 4,970 | 613 | **12.33%** |

### Step 3: is the difference real, or just luck? (Q4)

| Lift | Relative lift | z-score | 95% confidence interval |
|---:|---:|---:|---:|
| **+1.83 points** | +17.4% | **2.88** | +0.58 to +3.08 points |

- The **z-score of 2.88 is above 1.96**, so the result is statistically significant at the 95% level. A difference this large would be very unlikely if the two pages actually performed the same.
- The **confidence interval is above zero** across its whole range. Even in the most cautious case, page B still adds about half a point.

### Step 4: does it hold everywhere? (Q5, Q6)

| Device | Page A | Page B | Lift |
|---|---:|---:|---:|
| Desktop | 11.69% | 13.99% | +2.30 pts |
| Mobile | 9.74% | 11.25% | +1.52 pts |

- Page B wins on **both mobile and desktop**.
- Page B beat page A on **11 of the 14 days**, so the result is steady and not driven by one unusual day.

---

## Decision and recommendation

✅ **Switch to page B.** The new headline lifts the sign-up rate from 10.5% to 12.3%, and the result is significant and consistent.

**What it means for the business:** for every 10,000 visitors, page B brings in about **180 more free-trial sign-ups**.

**Next steps:**
1. Check whether page B's trial users go on to become **paying customers** at the same rate. More sign-ups only help if they also convert.
2. Test a further improvement on **mobile**, which has the lower sign-up rate on both pages.

---

## Project structure

```
ab-test-sql/
├── README.md
├── data/
│   ├── 01_create_table.sql       # creates the database and table
│   ├── 02_insert_data.sql        # loads the 10,000 visitors
│   └── ab_test_visitors.csv      # same data as a CSV file
├── queries/
│   └── ab_test_analysis.sql      # Q1–Q6: checks, results, z-test, breakdowns
└── scripts/
    └── generate_data.py          # recreates the dataset
```

---

## How to run it

1. Install **MySQL** (5.7 or 8.x) and a client such as **MySQL Workbench**.
2. Run `data/01_create_table.sql`. This creates the `ab_test` database.
3. Run `data/02_insert_data.sql`. This loads the data.
4. Run `queries/ab_test_analysis.sql`. Each question is labelled `Q1` … `Q6`.

To recreate the data, run `python scripts/generate_data.py` (Python 3, no extra packages needed).

---

## Skills demonstrated

- Designing an A/B test: control vs treatment, one main metric, a decision rule set in advance
- Checking that random assignment worked before trusting results
- Two-proportion **z-test** and **95% confidence interval** written in SQL
- Breaking results down by segment (device) and over time
- Turning a statistical result into a business recommendation

---

## AI assistance

This project was built with help from AI (Claude, by Anthropic). AI helped with:

- Writing the Python script that generates the synthetic dataset
- Writing and editing this README

My part was choosing the test design and decision rule, writing and running the queries in MySQL, checking the results, and interpreting the findings and recommendation. I can explain every query in this repository.
