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

select top 5 *
from employee;

select top 5 *
from employee
order by salary desc;

--Top 5 
select top 5 with ties name, salary
from employee
order by salary desc;

select top 30 percent with ties name, salary
from employee
order by salary desc;

select top 30 percent name, salary
from employee
order by salary desc;

--4th highest
select top 1 name, salary
from (select top 4 name,salary from employee order by salary desc) as T
order by salary asc;

--you may check the difference of the following
select top 5 name, salary
from employee
order by salary desc, name asc;

select top 5 name, salary
from employee
order by salary desc;

select top 5 with ties name, salary
from employee
order by salary desc;

select top 5 with ties name, salary
from employee
order by salary desc, name;