use university;

-- 1. Find the ID and name of each student who has not taken any course before the year 2018.

-- the first approach using not in

select	ID, name
from	student
where	ID not in (select	ID
				   from		takes
				   where	year < 2018);

/* We may also use except. But we need to guarantee that the two relations have
the same structure (https://www.w3schools.com/sql/sql_union.asp). 
So we need to join student and takes tables. */

select	ID, name
from	student
except
select	student.ID, name
from    student join takes
			on student.ID = takes.ID
where	year < 2018;

-- 2. Find the IDs of all students who were taught by an instructor named Katz; 
--    Make sure there are no duplicates in the result.

select	distinct takes.ID
from	takes join teaches
			on takes.course_id = teaches.course_id
			and	takes.sec_id = teaches.sec_id
			and	takes.semester = teaches.semester
			and	takes.year = teaches.year
		join instructor
			on teaches.ID = instructor.ID
where	instructor.name = 'Katz';

-- How to further find the names of such students?

-- 3. Find the total number of (distinct) students who have taken course sections 
--    taught by the instructor with ID 10101. 

select	count(distinct takes.ID)
from	takes join teaches			-- You may also use alias, e.g., TA for takes and TE for teaches
			on takes.course_id = teaches.course_id
			and	takes.sec_id = teaches.sec_id
			and	takes.semester = teaches.semester
			and	takes.year = teaches.year
where	teaches.ID = 10101;

-- 4. Find the departments with the budget over the average budget of all departments.

select	dept_name
from	department
where	budget > (select avg(budget) from department);

-- 5. Find all departments whose payroll (the sum of instructors’ salary) is greater
--    than the average payroll of all departments.

-- First check the payroll of each department
select	dept_name, sum(salary) as payroll
from	instructor
group by dept_name;

-- Next we may use the above query to create a temporary relation in the from clause.

select	dept_name
from	(select	dept_name, sum(salary) as payroll
		 from	instructor
		 group by dept_name) as dept_payroll
where	payroll > (select avg(payroll) from dept_payroll);

/* The above one looks good and clean, but not working :(
Reason: dept_payroll is just an inline view, which cannot be used on the right-hand side
in the where clause. This is the scope issue with the inline view. */

-- So we may try to expand the inline view in the where clause

select	dept_name
from	(select	dept_name, sum(salary) as payroll
		 from	instructor
		 group by dept_name) as dept_payroll
where	payroll > (select	avg(payroll) 
				   from		(select dept_name, sum(salary) as payroll
							 from	instructor
							 group by dept_name) as dept_payroll);

-- Now it works, but too complex!!

-- Do we have a way to define a temporary relation once that can be used in the whole query?
-- YES! We can use the with clause. The scope of with is the whole query
-- This is called a common table expression (CTE)
-- https://docs.microsoft.com/en-us/sql/t-sql/queries/with-common-table-expression-transact-sql?view=sql-server-ver15

with	dept_payroll (dept_name, payroll) as
			(select	dept_name, sum(salary)
			 from	instructor
			 group by dept_name)
select	dept_name
from	dept_payroll
where	payroll > (select avg(payroll) from dept_payroll);

-- Using CTE can significantly improve the readability.
-- We can also have multiple CTEs in a single with clause, separated by commas, as follows

with	dept_payroll (dept_name, payroll) as
			(select	dept_name, sum(salary)
			 from	instructor
			 group by dept_name),
		dept_payroll_avg(avg_payroll) as
			(select	avg(payroll)
			 from	dept_payroll)
select	dept_name
from	dept_payroll, dept_payroll_avg
where	payroll > avg_payroll;

-- 6. Find the department which has the lowest maximum salary. The result should display
--    the department name and the maximum salary within the department. 

-- Similarly, we can use a CTE to get the maximum salary of each department and then find
-- the department with the minimum maximum salary

with	dept_max_salary as
			(select	dept_name, max(salary) as max_salary
			 from	instructor
			 group by dept_name)
select	dept_name
from	dept_max_salary
where	max_salary = (select min(max_salary) from dept_max_salary);

-- 7. Find the course sections with the maximum enrollment, across all sections, in Fall 2017
-- We use a CTE to get the enrollment of each course section in Fall 2017

with	enrollment_fall_2017 as
			(select	course_id, sec_id, count(ID) as enrollment
			 from   takes
			 where	semester = 'Fall'
			 and	year = 2017
			 group by course_id, sec_id)
select	course_id, sec_id, enrollment
from	enrollment_fall_2017
where	enrollment = (select max(enrollment) from enrollment_fall_2017);

-- 8. Find the names of the students that did not take any courses.

-- Inner join by default 
select	*
from	student inner join takes			-- or just join
			on student.ID = takes.ID;

-- We can use left outer join to get the names of the students that did not take any courses.
select	name
from	student left outer join takes			-- or you can just use left join
			on student.ID = takes.ID
where	takes.ID is null;

-- You can also use not in
select	name
from	student
except
select	name
from	student join takes
			on student.ID = takes.ID
			
-- 9. Find the titles of the courses that were not taught by any instructors.

select	title
from	teaches right join course
			on teaches.course_id = course.course_id
where	ID is null;

-- 10. Find the instructors that did not teach any courses.

select	name
from	instructor left join teaches
			on instructor.ID = teaches.ID
where	teaches.ID is null;

-- The following returns the Cartesian product of two tables
--  Also called CARTESIAN JOIN or the CROSS JOIN 
-- (https://www.tutorialspoint.com/sql/sql-cartesian-joins.htm)

select	*
from	instructor, teaches;

-- 11. Create a view of the enrollment of each section that was offered in Fall 2017.

go	-- go is used to separate batches in SQL Server 
	-- (https://docs.microsoft.com/en-us/sql/t-sql/language-elements/sql-server-utilities-statements-go?view=sql-server-ver15)

create view enrollment_fall_2017 as
			select	course_id, sec_id, count(ID) as enrollment
			from	takes
			where	semester = 'Fall'
			and		year = 2017
			group by course_id, sec_id;
go

-- You may use the view as a table
select	*
from	enrollment_fall_2017;

-- Drop the view
drop view enrollment_fall_2017;

-- You can create a view from a view
-- First create a view of instructors without salary info

go 
create view faculty as
	select	ID, name, dept_name
	from	instructor;
go
-- Next create a view of Finance faculty only
create view faculty_finance as 
	select	*
	from	faculty
	where	dept_name = 'Finance';
go

select	*
from	faculty_finance;

-- Drop the views
drop view faculty_finance;
drop view faculty;

-- 12.	Give the average number of sections taught by each instructor who taught at 
--      least one course.

select (select count(*) from teaches)*1.0 / (select count(distinct ID) from teaches); 

-- 13. Create a new course “CS-001”, titled “Weekly Seminar”, with 0 credits.

-- The following will not run since credits must be greater than 0 
-- according to the check constraint in DDL

insert into course
	values ('CS-001', 'Weekly Seminar', 'Comp. Sci.', 0);
	
-- Modify the credits to 2
-- Use begin tran and rollback for transactions

begin tran;
	insert into course
		values ('CS-001', 'Weekly Seminar', 'Comp. Sci.', 2);
rollback;		-- or use commit the finalize the change

-- 14. Increase the salary of each instructor in the Comp. Sci. department by 10%.

begin tran;
	update	instructor
	set		salary = salary * 1.10
	where	dept_name = 'Comp. Sci.';
rollback;

-- 15. Insert every student whose tot_cred attribute is greater than 100 as an instructor in the same department, with a salary of 30,000.
-- Here is an example of inserting a table to another table

begin tran;
	insert into instructor
	select	ID, name, dept_name, 30000
	from	student
	where	tot_cred > 100;
rollback;

-- 16. Delete all rows in the instructor table for those instructors associated with a department located in the Watson building.

begin tran;
	delete from instructor 
	where	dept_name in (select dept_name
	                    from department                                      
						where building = 'Watson');
rollback;

-- 17. Increase salaries of instructors whose salary is over $90,000 by 3%, and all others by 5%.

begin tran;
	update	instructor           
	set		salary = salary * 1.03
	where	salary > 90000;
	update	instructor
	set		salary = salary * 1.05
	where	salary <= 90000;
rollback;

-- If we change the order of the two updates, some instructors' salaries increase twice

begin tran;
	update	instructor              
	set		salary = salary * 1.05             
	where	salary <= 90000;
	update	instructor
    set		salary = salary * 1.03
	where	salary > 90000;
rollback;

-- A better way using case

begin tran;
	update	instructor
	set		salary = case
			when salary <= 90000 then salary * 1.05                                  
			else salary * 1.03                                
	end;
rollback;

-- More case examples at https://www.w3schools.com/sql/sql_case.asp