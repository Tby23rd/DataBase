-- Please load the university database used in Assignment 1
use university;

-- The following command will check the existing index on a table
execute sp_helpindex student;

-- Only one clustered index is allowed per table
-- The clustered index cannot be created on dept_name
-- since there is one already created (the primary key ID). 
create clustered index ix_student_dept 
	on student (dept_name asc);

-- However, you can create multiple non-clustered indexes on a single table.

-- Create an index on dept_name
-- The default options to create an index: nonclustered and asc
create index ix_student_dept 
	on student (dept_name);

-- The above is the same as the following
create nonclustered index ix_student_dept 
	on student (dept_name asc);

-- Check the index again. "on PRIMARY" means that table is stored in main database file.
execute sp_helpindex student;

-- Drop the index
drop index ix_student_dept on student;

-- Check the Execution plan of the following query
-- Having an index does not mean the SQL Server must use it
-- In some situations, SQL Server finds that scanning the underlying table is faster than using the index, 
-- especially when the table is small, or the query returns most of the table records.

-- First make sure that a nonclustered index has been created on dept_name
create nonclustered index ix_student_dept 
	on student (dept_name asc);

-- The index will not be used in the following query

select	name
from	student
where	dept_name = 'Finance';

-- The index will be used in the following query since all the information can be
-- found in the index file

select	dept_name
from	student

drop index ix_student_dept on student;

-- Create an index on multiple columns
create index ix_student_name_dept 
	on student (name, dept_name);

-- The index will be used in the following query.	
select	name
from	student
where	dept_name = 'Finance';

drop index ix_student_name_dept on student;

-- Another way is to use include
create index ix_student_name_dept_include 
	on student (name) include (dept_name);

drop index ix_student_name_dept_include on student;

-- Execution plan

-- Early projections on tables instructor and teaches before 
-- join in the following query
select	name, course_id
from	instructor join teaches
			on instructor.ID = teaches.ID;

-- Additional early selection on instructor before join in the following query

select	name, course_id
from	instructor join teaches
			on instructor.ID = teaches.ID
where	instructor.dept_name = 'Biology';

-- Additional early selection on teaches before join in the following query
select	name, title
from	instructor join teaches
			on instructor.ID = teaches.ID
		join course
			on teaches.course_id = course.course_id
where	instructor.dept_name = 'Biology'
and		year = 2010;