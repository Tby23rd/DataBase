use master

drop database if exists TestDB;
go

create database TestDB;
go

use TestDB;

create table employee
	(name			varchar(20) not null, 
	 salary			numeric(8,2),
	 primary key (name)
);

insert into employee values ('Srinivasan', '90000');
insert into employee values ('Wu', '90000');
insert into employee values ('Mozart', '90000');
insert into employee values ('Einstein', '80000');
insert into employee values ('El Said', '80000');
insert into employee values ('Gold', '80000');
insert into employee values ('Katz', '70000');
insert into employee values ('Califieri', '70000');
insert into employee values ('Singh', '70000');
insert into employee values ('Crick', '60000');
insert into employee values ('Brandt', '60000');
insert into employee values ('Kim', '60000');

select	*
from	employee
order by salary desc;


-- top 1 on salary
select	top 1 name, salary
from	employee
order by salary desc;

-- top 1 with ties on salary
select	top 1 with ties name, salary
from	employee
order by salary desc;

-- The following is equivalent to top 1 with ties

select	name, salary
from	employee
where	salary = (select max(salary) from employee);

-- Top 5
select	top 5 name, salary
from	employee
order by salary desc;

-- Top 5 with ties
select	top 5 with ties name, salary
from	employee
order by salary desc;

-- If you compare the results of the above two queries, the order of records with the salary of 80000 may not be the same. 

-- Top 30%

select	top 30 percent name, salary
from	employee
order by salary desc;

-- Top 30% with ties

select	top 30 percent with ties name, salary
from	employee
order by salary desc;

-- Lowest salary
select	top 1 name, salary
from	employee
order by salary asc;

-- Second highest (can be tied)
select	top 1 name, salary
from	(select	top 2 name, salary from employee order by salary desc) as T
order by salary asc;

-- Fourth highest (can be tied)
select	top 1 name, salary
from	(select	top 4 name, salary from employee order by salary desc) as T
order by salary asc;


-- You may check the difference of the following two
select	top 5 name, salary 
from	employee 
order by salary desc;	-- order by salary in the descending order and then take the top 5; does not specify the order of other columns


select	top 5 name, salary 
from	employee 
order by salary desc, name asc; -- order by salary in the deseneding order and then by the name in the ascding order, and then take the top 5 rows


-- Why different number of rows for the following two?

select	top 5 with ties name, salary 
from	employee
order by salary desc;

select	top 5 with ties name, salary 
from	employee
order by salary desc, name asc;