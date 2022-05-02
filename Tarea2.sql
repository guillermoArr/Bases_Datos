--Tarea 2
--Tabla de emails

create table emails(
	registro_id numeric(4) constraint pk_registro_id primary key,
	nombre text not null,
	email varchar(100) not null
);
create sequence registro_id_seq start 1 increment 1;
alter table emails alter column registro_id set default nextval('registro_id_seq');

insert into emails 
(nombre, email)
values
('Wanda Maximoff', 'wanda.maximoff@avengers.org'),
('Pietro Maximoff', 'pietro@mail.sokovia.ru'),
('Erik Lensherr','fuck_you_charles@brotherhood.of.evil.mutants.space'),
('Charles Xavier', 'i.am.secretely.filled.with.hubris@xavier-school-4-gifted-youngste.'),
('Anthony Edward Stark', 'iamironman@avengers.gov'),
('Steve Rogers', 'americas_ass@anti_avengers'),
('The Vision',	'vis@westview.sword.gov'),
('Clint Barton', 'bul@lse.ye'),
('Natasja Romanov', 'blackwidow@kgb.ru'),
('Thor', 'god_of_thunder-^_^@royalty.asgard.gov'),
('Logan', 'wolverine@cyclops_is_a_jerk.com'),
('Ororo Monroe', 'ororo@weather.co'),
('Scott Summers', 'o@x'),
('Nathan Summers', 'cable@xfact.or'),
('Groot', 'iamgroot@asgardiansofthegalaxyledbythor.quillsux'),
('Nebula', 'idonthaveelektras@complex.thanos'),
('Gamora', 'thefiercestwomaninthegalaxy@thanos.'),
('Rocket', 'shhhhhhhh@darknet.ru');

select * from emails;

select e.nombre, e.email as "invalid email" from emails e where e.email not like '%@%.%' or e.email not like '@%' or e.email not like '%@'
or e.email like '%..%' or e.email like '%.' or e.email like '%!%' or e.email like '%^%' or e.email like '%@%@%' or email like '%&%'
or email like '%/%' or email like '%$%' or email like '%#%' or email like '%?%' or email like '%,%' or email like '%;%' or email like '% %'
or email like '%¡%' or email like '%\%' or email like '%(%' or email like '%)%' or email like '%"%' or email like '%|%' or email like '%=%'
or email like '%>%' or email like '%<%' or email like '%¿%' or email like '%+%' or email like '%¨%' or email like '%*%' or email like '%[%'or email like '%]%'
or email like '%}%' or email like '%{%' or email like '%:%';
