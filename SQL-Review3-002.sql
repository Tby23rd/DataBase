-- SQL Review 3

use TestDB;

-- Some more string operation examples

-- equals and like

drop table department;

create table department 
	(dept_name	varchar(20),
	 primary key(dept_name)
	); 

insert into department values ('comp%sci');
insert into department values ('comp_sci');

-- Use equals with no issues

select	*
from	department
where	dept_name = 'comp_sci';

select	*
from	department
where	dept_name = 'comp%sci';

-- Use like and wildcard show both rows

select	*
from	department
where	dept_name like 'comp_sci';

select	*
from	department
where	dept_name like 'comp%sci';

-- Use escape in like

select	*
from	department
where	dept_name like 'comp\_sci' escape '\';

select	*
from	department
where	dept_name like 'comp\%sci' escape '\';

-- You can define a different escape character
select	*
from	department
where	dept_name like 'comp!%sci' escape '!';


-- Work with null values

-- The result of any arithmetic expression involving null is null
select	5 + null;
select	0 * null;
select	null / 0;

-- Null values and aggregate functions
drop table employee;

create table employee 
	(name	varchar(20),
	 salary	numeric(8, 2),
	 bonus  numeric(8, 2),
	 primary key(name)
	); 

insert into employee values ('James', 30000, null);
insert into employee values ('Mike', null, null);
insert into employee values ('Diana', 40000, null);
insert into employee (name, salary) values ('David', 35000);

-- is not null
select	name
from	employee
where	salary is not null;

-- The result of any comparison involving a null value is unknown; 
-- Unknown is treated as false in the where clause.
-- Please check the Chapter3 slides on Null Values and Three Valued Logic
select	name
from	employee
where	salary <> NULL;

select	name
from	employee
where	salary != null or 1 = 1;	-- (unknown or true) = true

select	name
from	employee
where	salary != null and 1 = 1;	-- (unknown and true) = unknown, which is regarded as false
									-- in the where clause

select	name
from	employee
where	salary != null and 1 = 0;	-- (unknown and false) = false


-- Aggregate functions ignore tuples with null values
select	max(salary), min(salary), avg(salary), sum(salary), count(salary)
from	employee;

-- The bonus column only contains null values; count returns 0 and others return null
select	max(bonus), min(bonus), avg(bonus), sum(bonus), count(bonus)
from	employee;

-- isnull function, ISNULL(expression, value)
-- Return the specified value IF the expression is null; otherwise return the expression:

-- Return 5000 for salary if salary is null; otherwise return salary
select	name, isnull(salary, 1000*5)
from	employee;

-- Return 0 for salary if salary is null when computing the average salary;
-- You may compare with avg(salary) to see the difference

select	avg(isnull(salary, 0))
from	employee;


-- Create a user-defined table type
create type Dollars from numeric(12,2) NOT NULL;
go			

-- Use the defined type when creating a table 
create table employee2
	(ID				varchar(5), 
	 name			varchar(20) not null, 
	 salary			Dollars,
	 primary key (ID));

-- Need to drop the table using the type before dropping the type
drop table employee2;
drop type Dollars;

-- More on transactions
set xact_abort off;		-- Make sure that xact_abort is set to the default value (off)

delete from employee;
insert into employee values ('Diana', 40000, null);

/* The following will insert the first two rows; and once the transaction is committed, 
   we cannot roll it back. How can we achieve atomic transaction so the entire transaction 
   gets rolled back if there is an error? */
   
begin tran addEmp;	-- You may give a name to a transaction 
	insert into employee values ('James', 30000, null);
	insert into employee values ('Mike', null, null);
	insert into employee values ('Mike', 42000, null);
commit tran addEmp;	-- Once a transcation is committed, it cannot be rolled back.

select	*
from	employee;

-- The first approach, set the value of SET XACT_ABORT to on, which means if a Transact-SQL 
-- statement raises a run-time error, the entire transaction is terminated and rolled back.

delete from employee;
insert into employee values ('Diana', 40000, null);

-- The whole transaction will be rolled back in following
set xact_abort on;
begin tran;
	insert into employee values ('James', 30000, null);
	insert into employee values ('Mike', null, null);
	insert into employee values ('Mike', 42000, null);
commit;

select	*
from	employee;

-- The transaction will be committed in the following since there is no error

begin tran;
	insert into employee values ('James', 30000, null);
	insert into employee values ('Mike', null, null);
commit;

select	*
from	employee;

-- We can use the following command to check the current status of XACT_ABORT. 
-- The status is OFF by default.
if ( (16384 & @@OPTIONS) = 16384 ) print 'XACT_ABORT = ON' else print 'XACT_ABORT = OFF';

-- You may check more about @@options on 
-- https://docs.microsoft.com/en-us/sql/t-sql/functions/options-transact-sql?view=sql-server-ver15
-- https://www.mssqltips.com/sqlservertip/1415/determining-set-options-for-a-current-session-in-sql-server/

-- The second approach is to use the try/catch block. If an error occurs in the TRY block, 
-- control is passed to another group of statements that is enclosed in a CATCH block.

delete from employee;
insert into employee values ('Diana', 40000, null);

-- The transaction will be rolled back in the following
begin try
	begin tran;	
		insert into employee values ('James', 30000, null);
		insert into employee values ('Mike', null, null);
		insert into employee values ('Mike', 42000, null);
	commit;
end try
begin catch
	rollback;
end catch;
		
select	*
from	employee;

-- The transaction will be committed in the following
begin try
	begin tran;	 
		insert into employee values ('James', 30000, null);
		insert into employee values ('Mike', null, null);
	commit;
end try
begin catch
	rollback;
end catch;
		
select	*
from	employee;


-- Authorization

-- Create a login to connect to db engine
create login testUser with password = 'csis3300';	-- Passwords are case-sensitive
-- More explanation https://docs.microsoft.com/en-us/sql/t-sql/statements/create-login-transact-sql?view=sql-server-ver15

-- Create a user for university database and testUser login
use university;
create user test1 for login testUser;

-- Cannot create another user for the same database and the same login
create user test2 for login testUser;

-- You may create a user for the same login but a different database
use TestDB;
create user test1 for login testUser;

-- Drop the user
drop user test1;

-- Switch to the university database
use university;

-- Grant the select privilege on instructor table to test1
grant select on instructor to test1;

-- Revoke the granted select privilege on instructor to test1 
revoke select on instructor to test1;

-- Grant the select privilege on all tables/views in the database to test1
grant select to test1;
-- You may check https://sqlstudies.com/2014/05/15/granting-or-denying-permissions-to-the-tables-within-a-database/

-- Revoke the grant
revoke select to test1;

/* Note: you need to login the server as testUser to check how grant and revoke work for test1
Steps: 1. Click Connect and then click Database Engine.
	   2. In the Authentication drop-down list, select SQL Server Authentication.
       3. Enter testUser as login and csis3300 as the password. Click Connect.
	   4. You should now see a new connection as testUser in the Object Explorer window on the left.
	   5. Now you can right-click the connection and select New Query to run as test1.

If you did not enable SQL Server Authentication during the installation, you may check
https://www.dundas.com/support/learning/documentation/installation/how-to-enable-sql-server-authentication
*/

-- Create a view faculty and grant the select privilege on faculty to test1

go 
create view faculty as 
	select	name, dept_name
	from	instructor;
go

grant select on faculty to test1;

-- Revoke the grant
revoke select on faculty to test1;

-- More grant examples https://www.techonthenet.com/sql_server/grant_revoke.php

drop user test1;
drop login testUser;

-- In practice, we can use assign users to different roles. You may check the following website
-- https://docs.microsoft.com/en-us/sql/relational-databases/security/authentication-access/database-level-roles?view=sql-server-ver15