-- create schema pandemic2;

use pandemic2;

SELECT * FROM pandemic2.infectious_cases
limit 50;

select max(Length(Entity)), max(Length(Code)) from pandemic2.infectious_cases; 

create table if not exists country
(
id int auto_increment primary key,
entity varchar (34) not null, 
code varchar(8) not null 
);

-- insert into country (entity, code)
select distinct entity, code from infectious_cases;

select count(*), count(distinct entity, code) from country;

select count(distinct entity, code) from infectious_cases;

create table infectious_cases_norm like infectious_cases;

alter table infectious_cases_norm
add column country_id int first;

alter table infectious_cases_norm
drop column Entity, 
drop column Code;

alter table infectious_cases_norm 
add constraint infectious_cases_norm_country_fk
foreign key (country_id) references country(id);


alter table infectious_cases_norm 
add column inf_id int auto_increment primary key first;


insert into infectious_cases_norm
(
`country_id`,
`Year`,
`Number_yaws`,
`polio_cases`,
`cases_guinea_worm`,
`Number_rabies`,
`Number_malaria`,
`Number_hiv`,
`Number_tuberculosis`,
`Number_smallpox`,
`Number_cholera_cases`)
(
select
 `id`,
 `Year`,
 `Number_yaws`,
 `polio_cases`,
 `cases_guinea_worm`,
 `Number_rabies`,
 `Number_malaria`,
 `Number_hiv`,
 `Number_tuberculosis`,
 `Number_smallpox`,
 `Number_cholera_cases`
from infectious_cases as ic
inner join country as c on ic.Entity= c.entity and ic.Code= c.Code
);
-- truncate infectious_cases_norm; 
select * from infectious_cases_norm;

select country_id,
	avg(Number_rabies) average,
	min(Number_rabies) minimum,
	max(Number_rabies) maximum,
	sum(Number_rabies) summ
from infectious_cases_norm
where Number_rabies is not null and Number_rabies <> ''
group by country_id
order by average desc
limit 10;

select 
	Year, 
	makedate(Year, 1) first_day1,
	curdate() cur_day1,
	timestampdiff(Year, makedate(Year, 1), curdate()) as diff_years1
from infectious_cases_norm;

alter table infectious_cases_norm
add column first_day date,
add column cur_day date,
add column diff_years int;

select year, first_day, cur_day, diff_years from infectious_cases_norm;

select @@sql_safe_updates;
set @@sql_safe_updates=0;
update infectious_cases_norm set first_day=makedate(Year, 1);
select year, first_day, cur_day, diff_years from infectious_cases_norm;

update infectious_cases_norm set cur_day=curdate();
select year, first_day, cur_day, diff_years from infectious_cases_norm;

update infectious_cases_norm set diff_years=timestampdiff(Year, makedate(Year, 1), curdate());
select year, first_day, cur_day, diff_years from infectious_cases_norm;

drop function if exists diff_years;

delimiter //

create function diff_years(num year)
returns int 
deterministic 
no sql

begin
	return timestampdiff(Year, makedate(num, 1), curdate());
end //


delimiter ;

select year, diff_years(year) from infectious_cases_norm;

alter table infectious_cases_norm
add column diff_years1 int;

update infectious_cases_norm set diff_years1=diff_years(year);

select year, diff_years, diff_years1 from infectious_cases_norm;