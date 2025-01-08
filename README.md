
                                                                                   
Jules Niyitegeka
Final Project Data Analysis
Econ 970

Overview:
1. This file contains the analysis code for my final project, which uses the College Scorecard dataset to evaluate institutional performance and the factors influencing student outcomes.
2. The study focuses on institution-level data, including costs, student demographics, and outcomes such as graduation rates and 3-year student loan default rates, primarily for institutions participating in federal Title IV financial aid programs.
3. Data is aggregated from multiple sources, including the Integrated Postsecondary Education Data System (IPEDS), the National Student Loan Data System (NSLDS), and federal tax records, to track trends and variations over time.
   - Capturing key variables such as graduation rates, enrollments, average family income, and institutional characteristics (e.g., type, location, degree offerings).
   - Tracking institutions over time using unique crosswalks between IPEDS and Federal Student Aid identifiers.

1. Section 1: Cleaning
   - Addressing data limitations, such as the discontinuation of the 2-year default rate after 2011 and intermittent availability of post-graduation earnings data.
   - Calculating proxies like average family income for earnings and aggregating federal and Pell loan amounts to estimate student debt levels.
   - Preparing variables to regress the 3-year default rate on student demographics and institutional characteristics.

2. Section 2: Exploratory Data Analysis (EDA)
   - Generating summary tables and descriptive statistics for institutional performance measures.
   - Visualizing data trends across time and institutional categories.

3. Section 3: Analysis
   - Using regression models to analyze the relationships between student loan default rates and institutional characteristics.
   - Examining the impact of demographic and financial variables on default rates.
