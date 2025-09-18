# TEAM-5-Enterprise-Web-Development
Team Members:
Aurele Karega
Alain Christian Mugenga
Ella Reine Dusenayo
Nina Bwiza

# Project Description
This project processes MoMo SMS transaction data (XML format), cleans and categorizes it, stores it in a relational database (SQLite), and builds a frontend dashboard to analyze and visualize the data.



It demonstrates skills in:
- Backend data processing (ETL pipeline)
- Database management
- Frontend visualization
- Collaborative development workflows (Agile/Scrum, GitHub Projects)


# System Architecture
The system has three main layers:

1. *ETL Pipeline* – Parses raw MoMo XML → cleans → categorizes → loads into database → exports dashboard JSON  
2. *Database (SQLite)* – Stores structured transactions and categories  
3. *Frontend (HTML/CSS/JS)* – Reads processed JSON or API endpoints and displays charts/tables 

# Architecture Diagram:
Drawer.io link: https://app.diagrams.net/#G181WLpMhBhaiXU1itiynHxjx_8nNA2sX1#%7B%22pageId%22%3A%22ZCKRdisdFXJiV-nWuIja%22%7D
drive link: https://drive.google.com/file/d/181WLpMhBhaiXU1itiynHxjx_8nNA2sX1/view?usp=sharing

# Scrum Board
We are using *GitHub Projects* to manage tasks.  
[Team 5 Scrum Board](https://github.com/users/AureleKarega/projects/2) 

Columns used:
- *To Do*  
- *In Progress*  
- *Done*  

# Entity Relationship Diagram (ERD) Design
Draw.io link: https://drive.google.com/file/d/1tRqgZ-rjlXy6QHOeCOQVmFjhhe5QE9By/view?usp=sharing

# Documentation
The database layout is to balance the normalized relational modeling, querying, and practicality to ETL MoMo SMS data to customers, drivers, and system/service accounts users to avoid duplication and instead direct FK references are allowed between transaction and the sender and receiver user accounts to allow straightforward querying of the data to identify inflows/outflows per user. transaction categories is the business-level categorization of transaction (cash-in or cash-out, airtime); the category is kept normalized to allow easy updating of the data and consistent reporting. A transaction_ags + transaction tag link junction is added to facilitate flexible reporting and tagging (e.g. marking refunds, promotions, or ride payment payments) and allows transaction meta to be stored as JSON where it is of interest, allowing structured diagnostic interpretation whilst being relational (i.e. allowing relational querying). Timestamp, all sender/receiver FKs, and category indexes enhance performance of time-series analytics and user-level queries. CHECK constraints are used to provide data sanity (non-negative amounts, available phone numbers). In general, the design supports ETL atomic inserts as well as deterministic joins to support analytics and simple serialization to JSON to support the dashboard or API responses without closing the door to scale to either PostgreSQL or centralized analytical store in the future.
