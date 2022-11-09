insert into students values (7,'dua lipa',78,'2022-10-07'),
(8,'mike stan',34,'2022-10-07')

select * from students
select * from points

select distinct on (fname_lname) fname_lname, reg_date from students

-- LIKE
select * from students where fname_lname ~~ 'm%'  -- ILIKE is non-case sensitive 'ABC%' can abc ABc Abc etc. ~~ like, ~~* ilike, !~~ not like, !~~* not ilike

-- Limit offset
select * from students order by fname_lname desc limit 4 offset 3

-- concat
update students set fname_lname=fname_lname || 'bu ne laan'

--subqueries
update students
set fname_lname= (select points from points where student_id=1)+1
where id=1

--fetch
select * from students order by id
offset 3 rows
fetch first 2 row only


CREATE TABLE manav
(
isim varchar(50), 
Urun_adi varchar(50), 
Urun_miktar int
)

INSERT INTO manav VALUES( 'Ali', 'Elma', 5);
INSERT INTO manav VALUES( 'Ayse', 'Armut', 3);
INSERT INTO manav VALUES( 'Veli', 'Elma', 2);
INSERT INTO manav VALUES( 'Hasan', 'Uzum', 4);
INSERT INTO manav VALUES( 'Ali', 'Armut', 2);
INSERT INTO manav VALUES( 'Ayse', 'Elma', 3);
INSERT INTO manav VALUES( 'Veli', 'Uzum', 5);
INSERT INTO manav VALUES( 'Ali', 'Armut', 2);
INSERT INTO manav VALUES( 'Veli', 'Elma', 3);
INSERT INTO manav VALUES( 'Ayse', 'Uzum', 2);

-- Group by
SELECT  Urun_miktar, count(isim) AS Alan_kisi_sayisi
FROM manav
GROUP BY Urun_miktar


CREATE TABLE employee (
	employee_id INT PRIMARY KEY,
	first_name VARCHAR (255) NOT NULL,
	last_name VARCHAR (255) NOT NULL,
	manager_id INT,
	FOREIGN KEY (manager_id) 
	REFERENCES employee (employee_id) 
	ON DELETE CASCADE
);
INSERT INTO employee (
	employee_id,
	first_name,
	last_name,
	manager_id
)
VALUES
	(1, 'Windy', 'Hays', NULL),
	(2, 'Ava', 'Christensen', 1),
	(3, 'Hassan', 'Conner', 1),
	(4, 'Anna', 'Reeves', 2),
	(5, 'Sau', 'Norman', 2),
	(6, 'Kelsie', 'Hays', 3),
	(7, 'Tory', 'Goff', 3),
	(8, 'Salley', 'Lester', 3);
	
	select * from employee
	
-- Join INNER, LEFT, RIGHT, FULL OUTER, SELF, Cross, Natural
SELECT
    e.first_name || ' ' || e.last_name employee,
    m.first_name || ' ' || m.last_name manager
FROM
    employee e
INNER JOIN employee m ON m.employee_id = e.manager_id order by manager

-- Cross join
select * from employee cross join manav

-- Having
select isim , sum(urun_miktar) "total urun" from manav group by isim having sum(urun_miktar)>9

-- Union (Must have same number of columns and data type) union all show also duplicated rows    ,(employee_id),(employee_id,first_name)
SELECT * FROM table_name1
UNION
SELECT * FROM table_name2;

select employee_id, first_name,last_name from employee group by grouping sets( (first_name,last_name),(employee_id))

