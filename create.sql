create table students
( id int primary key,
 fname_lname varchar(30) not null,
 av_po real,
 reg_date date
)

create table points(
	student_id int check(student_id>0) not null,
	points int not null,
constraint avpo_fk foreign key(student_id) references students(id)
on delete cascade)

insert into points 
values
(1 , 89),
(2 , 71),
(3, 79 ),
(4, 57 ),
(5, 22 ),
(6, 98 )

update points
set points = 65 where student_id=4

select * from students where av_po in  (select points from points where points>60)