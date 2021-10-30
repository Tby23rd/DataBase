use university;



--1.Find the name of each instructor who has taught at least one course and the names of 
--the courses taught by each instructor.
--2. Find the name of each instructor in the History department who has taught at least one
--course and the names of the courses taught by each instructor.
--3. Find the name of each instructor whose name starts with letter "b" or "e".
--4. Find the name of each instructor whose name starts with letter "b", "c", "d", or "e".
--5. Find the name of each instructor whose name does not start with letter "b" or "e".
--6. Find the name of each instructor whose name has four letters.
--7. Find the name of each instructor whose name has 'a' as the second letter.
--8. Find the name of each instructor whose name starts with letter "b", "c", "d", "e", or "s" 
--and has 'i' as the second letter.
--9. Find instructors whose name has more than 6 letters.
--10. Give the first three letters of each instructor’s name in upper case.
--11. Give the name and department information of each instructor in the format 
--name@dept_name.

select concat(name, '@', 'dept_name')
from instructor;

--12. Find the name and department of each instructor; order the results first by the 
--department in the descending order and then by the name in the ascending order.

select name, dept_name
from instructor
order by dept_name desc, name asc;

--13. Find the name and salary of each instructor whose salary >=90000 and <=100000.

select name, salary
from instructor
where salary >= 90000
and salary <= 100000;

--14. Find the average of instructors’ salary of the department of Computer Science.

select avg(salary)
from instructor
where dept_name = 'Comp.Sci.';

--15. Give the number of rows in the course table.

select count(*)
from instructor;

select count(1)
from course;

--returns 1 from each row
select 1
from course;

--16. Find the average of instructors’ salary of each department.

select dept_name, avg(salary) as avg_salary
from instructor
group by dept_name;


--17. List all departments along with the number of instructors in each department.

select dept_name, count(ID) as num_of_instructor
from instructor
group by dept_name;

--18. Find the department name and average salary of each department with the average 
--salary greater than 80000.

--select dept_name, avg(salary) as avg_salary
--from instructor
--group by dept_name
--having avg_salary > 800000;


--19. Find the instructors who have the highest salary.

--select name 
--from instructor
--where salary = max(salary);--we may use a subquery


select name 
from instructor
where salary = (select max(salary) from instructor);


select top 1 name, salary
from instructor
order by salary desc;


--20. Find the name of each instructor whose salary is greater than the salary of all instructors 
--in the Finance department.

select name, salary

from instructor 

where salary >(

		 select MAX(salary)

		 from instructor

		 where dept_name='finance'

		);


		select *
		from instructor
		where dept_name = 'finance';



--21. Find the name of each instructor who has a higher salary than at least one instructor in 
--the Finance department.

		select name, dept_name
		from instructor
		where salary > all (select salary
							from instructor
							where dept_name = 'finance');

--22. Find the courses offered in Fall 2017 or Spring 2018.

select distinct course_id
from section
where semester = 'fall' and year = 2017
or semester = 'spring' and year = 2018;

(select course_id from section where semester = 'fall' and year = 2017)
union
(select course_id from section where semester = 'fall' and year = 2018)

(select course_id from section where semester = 'fall' and year = 2017)
union all
(select course_id from section where semester = 'fall' and year = 2018)



--23. Find the courses offered in both Fall 2017 and Spring 2018.

--select distinct course_id
--from section
--where (semester = 'fall' and year = 2017)
--and (semester = 'spring' and year = 2018);--does not work
select distinct course_id
from section
where semester = 'fall' and year = 2017
and course_id in (select course_id
				from section
				where semester = 'spring' and year = 2018);

--24. Find the courses offered in Fall 2017 but not Spring 2018.
(select course_id from section where semester = 'fall' and year = 2017)
except
(select course_id from section where semester = 'fall' and year = 2018)

select distinct course_id
from section
where semester = 'fall' and year = 2017
and course_id not in (select course_id
				from section
				where semester = 'spring' and year = 2018);

--25. Find all instructors not from History or Biology

select name, dept_name
from instructor
where dept_name != 'history'
and dept_name != 'biology';

select name, dept_name
from instructor
where dept_name not in ('history', 'biology');