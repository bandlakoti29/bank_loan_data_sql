select * from bank_loan_data;

--1.Total Loan Applications
select count(id) as total_loan_applications from bank_loan_data;

SELECT COUNT(id) AS MTD_total_loan_applications FROM bank_loan_data
WHERE issue_date >= '2021-12-01' AND issue_date <= '2021-12-31';

SELECT
        MONTH(issue_date) AS month,
        COUNT(id) AS total_app
    FROM bank_loan_data
    GROUP BY  MONTH(issue_date);


-- 2) calculating total loan amount 

select sum(loan_amount) as total_loan_amount from bank_loan_data;

select sum(loan_amount) as MTD_total_loan_amount from bank_loan_data
WHERE issue_date >= '2021-12-01' AND issue_date <= '2021-12-31';

with month_data(months,prev_month) as (select
     month(issue_date) as months,
     lag(loan_amount) over(order by month(issue_date)) as prev_month
from bank_loan_data)
select months,sum(prev_month) as PMTD_total_loan_amount from month_data
group by months
order by months;



-- 3) Total amount recieved
select sum(total_payment) as total_loan_payment from bank_loan_data;

select sum(total_payment) as MTD_total_loan_payment from bank_loan_data
WHERE issue_date >= '2021-12-01' AND issue_date <= '2021-12-31';

with month_data(months,prev_month) as (select
     month(issue_date) as months,
     lag(total_payment) over(order by month(issue_date)) as prev_month
     from bank_loan_data)
select months,sum(prev_month) as PMTD_total_loan_amount from month_data
group by months
order by months;

-- 4) calculating avg of interest of loans
select round(avg(int_rate),5)* 100 as avg_interest_rate from bank_loan_data;

select round(avg(int_rate),5)*100 as MTD_avg_interest_rate from bank_loan_data
WHERE issue_date >= '2021-12-01' AND issue_date <= '2021-12-31';

select round(avg(int_rate),5)*100 as PMTD_avg_interest_rate from bank_loan_data
where month(issue_date) = 11 and year(issue_date) = 2021;

-- Evaluating the average DTI 
select round(avg(dti),5) *100 as avg_DTI from bank_loan_data;

select round(avg(dti),5)*100 as MTD_avg_DTI from bank_loan_data
WHERE issue_date >= '2021-12-01' AND issue_date <= '2021-12-31';

select round(avg(dti),5)*100 as PMTD_avg_DTI from bank_loan_data
where month(issue_date) = 11 and year(issue_date) = 2021;

-- GOOD LOAND VS BAD LOANS
-- 1.Good Loan Application Percentage

select (count(id) * 1.0 /(select count(id) from bank_loan_data))*100  as total_good_loan_app_per from bank_loan_data
where loan_status in ('Fully Paid', 'Current');

-- 2.Good Loan Applications
select count(id)  as total_good_loan_app from bank_loan_data
where loan_status in ('Fully Paid', 'Current');

-- 3. Good Loan Funded Amount
select sum(loan_amount)  as good_loan_funded_amount from bank_loan_data
where loan_status in ('Fully Paid', 'Current');

--4.Good Loan Total Received Amount
select sum(total_payment) as good_loan_received_amount from bank_loan_data
where loan_status = 'Fully Paid' or loan_status = 'Current';

-- 5.Bad Loan Application Percentage
select (count(id) * 1.0 /(select count(id) from bank_loan_data))*100  as total_bad_loan_app_per from bank_loan_data
where loan_status in ('Charged Off');

-- 6.Bad Loan Applications
select count(id)  as total_bad_loan_app from bank_loan_data
where loan_status in ('Charged Off');

-- 7.Bad Loan Funded Amount
select sum(loan_amount)  as bad_loan_funded_amount from bank_loan_data
where loan_status in ('Charged Off');

--8.Bad Loan Total Received Amount
select sum(total_payment) as bad_loan_received_amount from bank_loan_data
where loan_status = 'Charged Off' ;


-- Loan Status Grid View
select 
      loan_status,
      count(id) as total_loan_applicants,
      sum(loan_amount) as total_funded_amount,
      sum(total_payment) as total_recieved_amount,
      avg(int_rate)*100 as average_interest_rate,
      avg(dti)*100 as average_dti
from bank_loan_data
group by loan_status;

-- month to date 
select
     loan_status,
     sum(loan_amount) as mtd_total_funded_amount,
     sum(total_payment) as mtd_total_amount_recieved
from bank_loan_data
where month(issue_date) = 12
group by loan_status;

-- month over month 
with month_data(months,loan_status,prev_month_loan,prev_month_payment) as (select
     month(issue_date) as months,
     loan_status,
     lag(loan_amount) over(order by month(issue_date)) as prev_month_loan,
     lag(total_payment) over(order by month(issue_date)) as prev_month_payment
from bank_loan_data)
select months,loan_status,sum(prev_month_loan) as Pmtd_total_funded_amount,sum(prev_month_payment) as Pmtd_total_amount_recieved
from month_data
group by months,loan_status
order by months,loan_status;

-- Metrics: 'Total Loan Applications,' 'Total Funded Amount,' and 'Total Amount Received by month' 
select 
      month(issue_date) as month_number,
      DATENAME(month,issue_date) as month_name,
      count(id) as total_loan_applicants,
      sum(loan_amount) as total_funded_amount,
      sum(total_payment) as total_amount_recieved
 from bank_loan_data
 group by month(issue_date),DATENAME(month,issue_date)
 order by month_number;

-- Metrics: 'Total Loan Applications,' 'Total Funded Amount,' and 'Total Amount Received by state' 
 select 
      address_state,
      count(id) as total_loan_applicants,
      sum(loan_amount) as total_funded_amount,
      sum(total_payment) as total_amount_recieved
 from bank_loan_data
 group by address_state
 order by address_state;

-- Metrics: 'Total Loan Applications,' 'Total Funded Amount,' and 'Total Amount Received by term' 
 select 
      term,
      count(id) as total_loan_applicants,
      sum(loan_amount) as total_funded_amount,
      sum(total_payment) as total_amount_recieved
 from bank_loan_data
 group by term
 order by term;

-- Metrics: 'Total Loan Applications,' 'Total Funded Amount,' and 'Total Amount Received by employee experience' 
 select 
      emp_length as emp_experience,
      count(id) as total_loan_applicants,
      sum(loan_amount) as total_funded_amount,
      sum(total_payment) as total_amount_recieved
 from bank_loan_data
 group by emp_length
 order by emp_length;


-- Metrics: 'Total Loan Applications,' 'Total Funded Amount,' and 'Total Amount Received by home_ownership' 
 select 
      home_ownership,
      count(id) as total_loan_applicants,
      sum(loan_amount) as total_funded_amount,
      sum(total_payment) as total_amount_recieved
 from bank_loan_data
 group by home_ownership
 order by count(id);
