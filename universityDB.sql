--SHOW search_path;
--set search_path to university;

CREATE TABLE university.faculties (
	id bigserial NOT NULL,
	fac_name character varying(30) NOT NULL,
	PRIMARY KEY (id)
);

CREATE TABLE university.students (
	id bigserial NOT NULL,
	birth_date date NOT NULL,
 first_name character varying(20) NOT NULL,
 last_name character varying(20) NOT NULL,
 faculty_id bigserial NOT NULL,
 PRIMARY KEY (id),
	FOREIGN KEY (faculty_id)
		REFERENCES faculties(id)
		ON DELETE CASCADE
);

CREATE TABLE university.professors (
	id bigserial NOT NULL,
	first_name character varying(20) NOT NULL,
	last_name character varying(20) NOT NULL,
	PRIMARY KEY (id)
);

CREATE TABLE university.courses (
	id bigserial NOT NULL,
	course_name character varying(30) NOT NULL,
	course_type character varying(20) NOT NULL,
	CHECK
	( course_type IN ('BASE', 'MFK', 'SPEC')
	),
	PRIMARY KEY (id)
);

CREATE TABLE university.marks (
	score int NOT NULL,
	student_id bigserial NOT NULL,
	course_id bigserial NOT NULL,
	score_date date NOT NULL,
	status character varying(10) NOT NULL,
	CHECK
	( score IN (2, 3, 4, 5)
	),
	CHECK
	( status IN ('passed', 'retaken')
	),
	PRIMARY KEY (student_id, course_id, score_date),
	FOREIGN KEY (student_id)
		REFERENCES university.students(id)
		ON DELETE CASCADE,
	FOREIGN KEY (course_id)
		REFERENCES university.courses(id)
		ON DELETE CASCADE
);

--drop table university.marks

CREATE TABLE university.faculties_courses (
	faculty_id bigserial NOT NULL,
	course_id bigserial NOT NULL,
	professor_id bigserial NOT NULL,
	PRIMARY KEY (faculty_id, course_id, professor_id),
	FOREIGN KEY (faculty_id)
		REFERENCES faculties(id)
		ON DELETE CASCADE,
	FOREIGN KEY (course_id)
		REFERENCES courses(id)
		ON DELETE CASCADE,
	FOREIGN KEY (professor_id)
		REFERENCES professors(id)
		ON DELETE CASCADE
);

CREATE TABLE university.achievements (
	student_id bigserial NOT NULL,
	count_of_five int,
	PRIMARY KEY (student_id)
);

--drop table university.achievements

CREATE TABLE university.additional_courses (
	student_id bigserial NOT NULL,
	course_id bigserial NOT NULL,
	PRIMARY KEY (student_id, course_id),
	FOREIGN KEY (student_id)
		REFERENCES university.students(id)
		ON DELETE CASCADE,
	FOREIGN KEY (course_id)
		REFERENCES university.courses(id)
		ON DELETE CASCADE
);

create table university.exam_schedule (
	faculty_id bigserial NOT NULL,
	course_id bigserial NOT NULL,
	exam_date date NOT NULL,
	primary key (faculty_id, course_id),
	foreign key (course_id)
		references university.courses(id)
		on delete cascade,
	foreign key (faculty_id)
		references university.faculties(id)
		on delete cascade
);

--drop table exam_schedule
--insert into university.exam_schedule (faculty_id, course_id, exam_date) values (1, 1, '2002-10-06')
--select * from university.exam_schedule





-- Testing

-- insert into university.faculties
-- 	(fac_name)
-- 	values ('MechandMat')

-- insert into university.faculties
-- 	(fac_name)
-- 	values ('FSR')

-- insert into university.faculties
-- 	(fac_name)
-- 	values ('VMK')

--select * from university.faculties

-- insert into university.students
--  (birth_date, first_name, last_name, faculty_id)
--  values ('1999-10-06', 'VASa', 'PUPkin', 1)

-- insert into university.students
--  (birth_date, first_name, last_name, faculty_id)
--  values ('1999-10-06', 'gena', 'bUkin', 2)

-- insert into university.students
--  (birth_date, first_name, last_name, faculty_id)
--  values ('1999-10-06', 'fedya', 'ludoch', 3)

-- select * from university.students

-- insert into university.professors
-- 	(first_name, last_name)
-- 	values ('Инна', 'Садовничая')

-- insert into university.professors
-- 	(first_name, last_name)
-- 	values ('Артём', 'Савчук')

-- select * from university.professors

-- insert into university.courses
-- 	(course_name, course_type)
-- 	values ('Matan', 'BASE')

-- insert into university.courses
-- 	(course_name, course_type)
-- 	values ('FUNCAN', 'MFK')

-- insert into university.courses
-- 	(course_name, course_type)
-- 	values ('ICPC', 'SPEC')

-- insert into university.courses
-- 	(course_name, course_type)
-- 	values ('lalala', 'BASE')

-- select * from university.faculties
-- select * from university.courses
-- select * from university.professors

--    insert into university.faculties_courses
--    	(faculty_id, course_id, professor_id)
--    	values (3, 1, 1)

--  insert into university.faculties_courses
--    	(faculty_id, course_id, professor_id)
--    	values (4, 5, 2)

--  insert into university.faculties_courses
--    	(faculty_id, course_id, professor_id)
--    	values (2, 3, 2)

--select * from university.faculties_courses

--   insert into university.marks
--   	(score, student_id, course_id)
--   	values (5, 1, 3)

--   insert into university.marks
--   	(score, student_id, course_id)
--   	values (4, 1, 2)

-- 	  insert into university.marks
--   	(score, student_id, course_id)
--   	values (3, 1, 3)

--  select * from university.marks










-- View и хранимые процедуры

-- 1) view предметы по факультету

create view university.subjects_at_the_faculty as
	select faculty_id, fac_name, course_id, course_name, course_type
		from university.faculties_courses fc left join university.faculties f
			on fc.faculty_id = f.id
		left join university.courses c
			on fc.course_id = c.id
	order by faculty_id

--select * from university.subjects_at_the_faculty

--select * from university.courses

--select * from university.faculties_courses

--drop view university.subjects_at_the_faculty

-- 2) хранимая процедура Добавить студента

create or replace procedure university.add_student(
    need_birth_date date,
    need_first_name character varying,
    need_last_name character varying,
    need_faculty_id int
)
language plpgsql
as $$
begin
	if exists (select 1 from university.students s
		where s.birth_date = need_birth_date and
     		s.first_name = need_first_name and
  			s.last_name = need_last_name) then
    	rollback;
	else
		insert into university.students (
			birth_date, first_name, last_name, faculty_id
			)
			values (
				need_birth_date, need_first_name, need_last_name, need_faculty_id
			);
		commit;
	end if;
end;
$$

--drop procedure university.add_student

--call university.add_student('3333-11-11', 'Zheka', 'Ahekovich', 1);

--select * from university.students


-- 3) хранимая процедура Удаляет преподавателя (нельзя, если он ведёт курсы)

--select * from university.professors

--select * from university.faculties_courses

create or replace procedure university.remove_professor(
	need_id int
)
language plpgsql
as $$
begin
	if need_id in (select professor_id from university.faculties_courses) then
		rollback;
	else
		delete from university.professors
			where id = need_id;
		commit;
	end if;
end;
$$

--call university.remove_professor(4)

--drop procedure university.remove_professor


-- 4) хранимая процедура (запись студента на курс) добавляет курс если он не base и если он ещё не добавлен для студента.

create or replace procedure university.enrolling_student(
	stud_id int,
	cour_id int
)
language plpgsql
as $$
begin
	if exists (select 1 from university.courses c where c.id = cour_id)
		and exists (select 1 from university.students s where s.id = stud_id) then
		if exists (select 1 from university.courses where course_type = 'BASE' and id = cour_id) then
			raise info '111 course not can be type base';
			rollback;
			return;
		else
			if cour_id in (select course_id from university.additional_courses) then
				raise info '222 course not can be type base';
				rollback;
				return;
			end if;
		end if;
		insert into university.additional_courses (student_id, course_id) values (stud_id, cour_id);
		insert into university.achievements (student_id, count_of_five) values (stud_id, 0);
		raise info 'succesfull add course';
		commit;
	else
		raise info '333 course not can be type base';
		rollback;
	end if;
end;
$$

--select * from university.students

--select * from university.courses

--select * from university.additional_courses
--select * from university.achievements

--call university.enrolling_student(1, 3)

--TRUNCATE university.additional_courses;



-- Хранимая для подсчёта количества пятёрок (лучшие результаты)

create or replace procedure university.counter_of_fives_by_student_id(
	stud_id int
)
language plpgsql
as $$
	declare counter int;
begin
	counter = (select count(*) from university.marks where score = 5 and student_id = stud_id);
	if exists (select 1 from university.achievements where student_id = stud_id) then
		update university.achievements set count_of_five = counter
			where student_id = stud_id;
	else
		insert into university.achievements (student_id, count_of_five) values (stud_id, counter);
	end if;
end;
$$

--call university.counter_of_fives_by_student_id(2)

--select * from university.achievements






-- Тригеры

--1) Идёт пересчёт количества пятёрок у студента после добавления ему оценки.

create or replace function university.recalculate_achievements() returns trigger as $emp_stamp$
	begin
		call university.counter_of_fives_by_student_id(CAST(new.student_id as int));
		return new;
	end;
$emp_stamp$ LANGUAGE plpgsql;

create or replace trigger recalculate_achievements after INSERT on university.marks
    for each row execute procedure university.recalculate_achievements();

--select * from university.marks
--select * from university.courses
--select * from university.achievements
--select * from university.students

-- 	  insert into university.marks
--   	(score, student_id, course_id, score_date, status)
--   	values (5, 8, 1, '2002-10-06', 'passed')

-- 2) Запись о "пересдаче", если оценка получена после определенной даты

create or replace function university.pass_check() returns trigger as $emp_stamp$
	begin
		if new.score_date > (select exam_date from university.exam_schedule where course_id = new.course_id) then
			raise info 'retaken';
			new.status = 'retaken';
		else
			raise info 'passed';
			new.status = 'passed';
		end if;
		return new;
	end;
$emp_stamp$ LANGUAGE plpgsql;

create or replace trigger pass_check before INSERT on university.marks
    for each row execute procedure university.pass_check();


--insert into university.exam_schedule (faculty_id, course_id, exam_date) values (2, 2, '1999-11-05')
--select * from university.exam_schedule

--truncate table university.marks

--select * from university.marks

-- 	  insert into university.marks
--   	(score, student_id, course_id, score_date, status)
--   	values (5, 2, 2, '1999-12-05', 'passed')
