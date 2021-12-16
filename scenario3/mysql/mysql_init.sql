create table users(
	id varchar(50) primary key,
	name varchar(50),
	nickname varchar(50),
	gender int(10),
	disabled tinyint(1),
	username varchar(50),
	password varchar(256),
	address text,
	email varchar(80),
	phone varchar(50)
);
