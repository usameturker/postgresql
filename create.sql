/*create table students
( id char(4),
 fname_lname varchar(30),
 av_po real,
 reg_date date
)*/

create table av_points
as select fname_lname, av_po
from students