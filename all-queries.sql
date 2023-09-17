-- See all values contained in customers table
select * from customers;

-- Check how active our employees are, including blank employees
select e.employeeNumber, concat(e.firstName, " ", e.lastName) as employeeName, count(*) as frequency
from employees as e
right join customers as c on e.employeeNumber = c.salesRepEmployeeNumber
group by 1
order by 3 desc;

-- Distribution of every office's employees
select officeCode, count(employeeNumber) as employeeAmounts from employees group by 1;

-- Check all distinct orders' status
select status, count(*) as statusCount from orders group by 1;

-- Select all orders that have already paid
select * from orders where status in ("Shipped", "Resolved");

-- Compare the revenue and cost of all orders
select *, (totalRevenue - totalCost) as profit
from (
select 
	o.orderNumber, 
    sum(od.quantityOrdered * od.priceEach) as totalRevenue, 
    sum(od.quantityOrdered * p.buyPrice) as totalCost
from orders o
# Get the revenue #
join orderdetails od on o.orderNumber = od.orderNumber
# Get the cost #
join products p on od.productCode = p.productCode
group by 1) revenue_cost;

-- Check if customers' payments are the same as in payment check
with paidTable as (
	select
		o.customerNumber,
		sum(od.quantityOrdered * od.priceEach) as totalPaid
	from orders o
	# Get the totalPaid #
	join orderdetails od on o.orderNumber = od.orderNumber
    where o.status in ("Shipped", "Resolved")
    group by 1
),
checkTable as (
	select
		pt.customerNumber,
        pt.totalPaid,
		sum(p.amount) as paidAmount
	from paidTable pt
	# Get the totalPaid #
    join payments p on pt.customerNumber = p.customerNumber
    group by 1
)
select sameAmount, count(*) as totalCount
from (
	select *, case when totalPaid = paidAmount then "Yes" else "No" end as sameAmount
	from checkTable
) tableCompared