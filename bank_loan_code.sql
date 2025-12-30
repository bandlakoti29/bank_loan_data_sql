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

--9 Adding recovery rate from good loans
with recovery_rate_chargedoff(total_amount_received,total_amount_funded) as (select 
                              sum(total_payment) as total_amount_received,sum(loan_amount) as total_amount_funded
                              from bank_loan_data
                              where loan_status in ('Fully Paid','Current'))
select 
      (total_amount_received * 1.0 / total_amount_funded) * 100 AS recovery_percentage,
      case 
         when (total_amount_received * 1.0/total_amount_funded)*100 >= 100 then 'in profits' 
         else 'In Losses'
         end as profit_loss,
         case 
          when (total_amount_received * 1.0/total_amount_funded)*100 <= 100 then -(100 - (total_amount_received * 1.0/total_amount_funded)*100)
          else +((total_amount_received * 1.0/total_amount_funded)*100) - 100
          end as difference_per
from recovery_rate_chargedoff;

--10. Adding recover rate from bad loans
with recovery_rate_chargedoff(total_amount_received,total_amount_funded) as (select 
                              sum(total_payment) as total_amount_received,sum(loan_amount) as total_amount_funded
                              from bank_loan_data
                              where loan_status in ('Charged Off'))
select 
      (total_amount_received * 1.0 / total_amount_funded) * 100 AS recovery_percentage,
      case 
         when (total_amount_received * 1.0/total_amount_funded)*100 >= 100 then 'in profits'
         when (total_amount_received * 1.0/total_amount_funded)*100 >= 100 then 'in p'
         else 'In Losses'
         end as profit_loss,

      case 
          when (total_amount_received * 1.0/total_amount_funded)*100 <= 100 then -(100 - (total_amount_received * 1.0/total_amount_funded)*100)
          else +(100 - (total_amount_received * 1.0/total_amount_funded)*100)
          end as difference_per
from recovery_rate_chargedoff;

-- 11 Bad Loan percentage by state
with recovery_rate_badloan(address_state,total_received,total_funded) as (select
        address_state,
        sum(total_payment) as total_received,
        sum(loan_amount) as total_funded
    from bank_loan_data
    where loan_status = 'Charged Off'
    group by address_state)
select address_state,total_received,total_funded,
       (total_received *1.0/total_funded) *100 as states_per
from recovery_rate_badloan;

-- Good Loan Percentage by state
with recovery_rate_goodloan(address_state,total_received,total_funded) as (select
        address_state,
        sum(total_payment) as total_received,
        sum(loan_amount) as total_funded
    from bank_loan_data
    where loan_status = 'Current' or loan_status = 'Fully Paid'
    group by address_state)
select address_state,total_received,total_funded,
       (total_received *1.0/total_funded) *100 as states_per
from recovery_rate_goodloan;

-- Good loan percentage by term
with recovery_rate_goodloan(term,total_received,total_funded) as (select
        term,
        sum(total_payment) as total_received,
        sum(loan_amount) as total_funded
    from bank_loan_data
    where loan_status = 'Fully Paid' or loan_status = 'Current'
    group by term)
select term,total_received,total_funded,
       (total_received *1.0/total_funded) *100 as term_per
from recovery_rate_goodloan;

-- bad loan percentage by term
with recovery_rate_badloan(term,total_received,total_funded) as (select
        term,
        sum(total_payment) as total_received,
        sum(loan_amount) as total_funded
    from bank_loan_data
    where loan_status = 'Charged Off'
    group by term)
select term,total_received,total_funded,
       (total_received *1.0/total_funded) *100 as term_per
from recovery_rate_badloan;


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


--Monthly Loan Applications + MoM Growth percentage
with monthly_apps as (
    select
        year(issue_date) as yr,
        month(issue_date) as mn,
        count(id) as total_applications
    from bank_loan_data
    group by year(issue_date), month(issue_date)
)
select
    yr,
    mn,
    total_applications,
    lag(total_applications) over(order by yr, mn) as prev_month_apps,
    round(
        (total_applications - lag(total_applications) over (order by yr, mn)) * 100.0
        / nullif(lag(total_applications) over (order by yr, mn), 0),
        2
    ) as MoM_growth_percent
from monthly_apps
order by yr, mn;

--Monthly Funded Amount + MoM Growth percentage
with monthly_funding as (
    select
        year(issue_date) as yr,
        month(issue_date) as mn,
        sum(loan_amount) as total_funded_amount
    from bank_loan_data
    group by year(issue_date), month(issue_date)
)
select
    yr,
    mn,
    total_funded_amount,
    lag(total_funded_amount) over (order by yr, mn) as prev_month_funded,
    round(
        (total_funded_amount - lag(total_funded_amount) over (order by yr, mn)) * 100.0
        / nullif(lag(total_funded_amount) over (order by yr, mn), 0),
        2
    ) as mom_growth_percent
from monthly_funding
order by yr, mn;

--ranking by states for good loan
with recovery_rate_goodloan as (
    select
        address_state,
        sum(total_payment) as total_received,
        sum(loan_amount) as total_funded
    from bank_loan_data
    where loan_status in ('Current', 'Fully Paid')
    group by address_state
)
select
    address_state,
    total_received,
    total_funded,
    round((total_received * 1.0 / total_funded) * 100, 2) as good_recovery_percent,
    rank() over (
        order by (total_received * 1.0 / total_funded) desc
    ) as state_rank
from recovery_rate_goodloan
order by state_rank;

-- ranking by all states
with recovery_rate as (
    select
        address_state,
        sum(total_payment) as total_received,
        sum(loan_amount) as total_funded
    from bank_loan_data
    where loan_status in ('Current', 'Fully Paid','Charged Off')
    group by address_state
)
select
    address_state,
    total_received,
    total_funded,
    round((total_received * 1.0 / total_funded) * 100, 2) as good_recovery_percent,
    rank() over (
        order by (total_received * 1.0 / total_funded) desc
    ) as state_rank
from recovery_rate;
