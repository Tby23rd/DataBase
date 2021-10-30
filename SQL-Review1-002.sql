use university;

/* 1. Find the name of each instructor who has taught at 
      least one course and the names of the courses taught by each instructor. */

select	distinct name, title
from	instructor join teaches
			on instructor.ID = teaches.ID
		join course
			on teaches.course_id = course.course_id;
			
/* 2. Find the name of each instructor in the History department who has taught 
      at least one course and the names of the courses taught by each instructor.*/

select	distinct name, title
from	instructor join teaches
			on instructor.ID = teaches.ID
		join course
			on teaches.course_id = course.course_id
where	instructor.dept_name = 'History';


-- The following using implict join is not recommended. Use join on to join tables
select	distinct name, title
from	instructor, teaches, course
where	instructor.ID = teaches.ID
and		teaches.course_id = course.course_id
and		instructor.dept_name = 'History';

-- 3. Find the name of each instructor whose name starts with letter "b" or "e".

select	name
from	instructor
where	name like '[be]%';

-- 4. Find the name of each instructor whose name starts with letter "b", "c", "d", or "e".

select	name
from	instructor
where	name like '[b-e]%';

-- 5. Find the name of each instructor whose name does not start with letter "b" or "e".

select	name
from	instructor
where	name not like '[be]%';

-- or the following

select	name
from	instructor
where	name like '[^be]%';

-- 6. Find the name of each instructor whose name has four letters.

select	name
from	instructor
where	name like '____'

-- Using len is recommended
select	name
from	instructor
where	len(name) = 4;

-- 7. Find the name of each instructor whose name has 'a' as the second letter.

select	name
from	instructor
where	name like '_a%';

-- 8. Find the name of each instructor whose name starts with 
--    letter "b", "c", "d", "e", or "s" and has 'i' as the second letter.

select	name
from	instructor
where	name like '[b-es]i%'

-- 9. Find instructors whose name has more than 6 letters.

select	name
from	instructor
where	len(name) > 6;

-- 10. Give the first three letters of each instructor’s name in upper case.
	
select	upper(substring(name, 1, 3))		-- start from index 1, with the length of 3 letters
from	instructor;

-- 11. Give the name and department information of each instructor in the format name@dept_name.

select	concat(name, '@', dept_name)
from	instructor;

-- You may also use the plus (+) operator 
select	name + '@' + dept_name
from	instructor;

-- But concat has better readability and it handles NULL values well. 
-- You may check https://www.mssqltips.com/sqlservertip/2985/concatenate-sql-server-columns-into-a-string-with-concat/

/* 12. Find the name and department of each instructor; order the results first by the 
       department in the descending order and then by the name in the ascending order. */

select	name, dept_name
from	instructor
order by dept_name desc, name asc;

-- 13. Find the name and salary of each instructor whose salary >=90000 and <=100000.

select	name, salary
from	instructor
where	salary >= 90000
and		salary <= 100000;

-- or use between
select	name, salary
from	instructor
where	salary between 90000 and 100000;

-- note: between would include both numbers

-- 14. Find the average of instructors’ salary of the department of Computer Science.
select	avg(salary) as cs_avg_salary
from	instructor
where	dept_name = 'Comp. Sci.';

-- 15. Give the number of rows in the course table.

select	count(*)
from	course;

-- You may also see the following in many cases, which is the same

select	count(1)
from	course;

-- 16. Find the average of instructors’ salary of each department.

select	dept_name, avg(salary) as avg_salary
from	instructor
group by dept_name;

-- 17. List all departments along with the number of instructors in each department.

select	dept_name, count(ID) as num_of_instructors
from	instructor
group by dept_name;

/* 18. Find the department name and average salary of each department with the 
       average salary greater than 80000. */

select	dept_name, avg(salary) as avg_salary
from	instructor
group by dept_name
having	avg(salary) > 80000;

-- the following will not work

select	dept_name, avg(salary) as avg_salary
from	instructor
group by dept_name
having	avg_salary > 80000;	 -- SQL Server does not allow having clause to use the alias in select cause

-- 19. Find the instructors who have the highest salary.

-- a common mistake in CSIS 2300
select  name
from	instructor
where	salary = max(salary);

-- Use a subquery in the where clause
select	name
from	instructor
where	salary = (select max(salary) from instructor);

-- or use top

select top 1 name
from	instructor
order by salary desc;

-- If there are ties, need to use with ties

select top 1 with ties name
from	instructor
order by salary desc;

-- We can also use top to get the first n rows of a table or column (no order)

select	top 5 *
from	instructor;

select	top 5 name
from	instructor

/* 20. Find the name of each instructor whose salary is greater than the salary of 
       all instructors in the Finance department. */

select	name
from	instructor
where	salary > (select max(salary)
				  from	instructor
				  where	dept_name = 'Finance');

-- the second approach is to use all

select	name
from	instructor
where	salary > all (select salary
					  from	instructor
					  where	dept_name = 'Finance');

/* 21. Find the name of each instructor who has a higher salary than 
       at least one instructor in the Finance department. */

select	name
from	instructor
where	salary > (select min(salary)
				  from	instructor
				  where	dept_name = 'Finance');


-- Another method using some.
select	name
from	instructor
where	salary > some (select salary
					  from	instructor
					  where	dept_name = 'Finance');

-- You can also use any, which is equivalent to some
select	name
from	instructor
where	salary > any (select salary
					  from	instructor
					  where	dept_name = 'Finance');

-- Another method using self join
select	distinct T.name
from	instructor as T, instructor as S
where	T.salary > S.salary
and		S.dept_name = 'Finance';

-- 22. Find the courses offered in Fall 2017 or Spring 2018. 
select	distinct course_id
from	section									-- You may use the teaches table as well
where	(semester = 'Fall' and year = 2017)
or		(semester = 'Spring' and year = 2018);

-- another method that uses the keyword union.
(select	course_id from section where semester = 'Fall' and year = 2017)
union
(select	course_id from section where semester = 'Spring' and year = 2018)

-- Note: union would remove the duplicate automatically. You can use union all to keep duplicates

-- 23. Find the courses offered in both Fall 2017 and Spring 2018.

-- The following one seems right, but not correct
select	distinct course_id
from	section
where	(semester = 'Fall' and year = 2017)
and		(semester = 'Spring' and year = 2018);

-- we can use intersect

(select	course_id from section where semester = 'Fall' and year = 2017)
intersect
(select	course_id from section where semester = 'Spring' and year = 2018)

-- You can also use subquery and in

select	distinct course_id
from	section
where	semester = 'Fall' and year =2017
and		course_id in (select course_id
					  from	 section
					  where	semester = 'Spring' and year = 2018);
					  
-- 24. Find the courses offered in Fall 2017 but not Spring 2018.

(select	course_id from section where semester = 'Fall' and year = 2017)
except
(select	course_id from section where semester = 'Spring' and year = 2018)

-- or use not in

select	distinct course_id
from	section
where	semester = 'Fall' and year =2017
and		course_id not in (select course_id
					  from	 section
					  where	semester = 'Spring' and year = 2018);

-- 25. Find all instructors not from History or Biology.

select	name, dept_name
from	instructor
where	dept_name != 'History'
and		dept_name !='Biology';

-- Use not in, which has better readability and can be easily extended
select	name, dept_name
from	instructor
where	dept_name not in ('History', 'Biology');