create DATABASE TestDB;
GO

USE TestDB;
GO

create table users(
	id varchar(50) primary key,
	name varchar(50),
	nickname varchar(50),
	gender int,
	disabled bit,
	username varchar(50),
	password varchar(256),
	email varchar(80),
	phone varchar(50)
);
GO

EXEC sys.sp_cdc_enable_db
GO

EXEC sys.sp_cdc_enable_table
@source_schema = N'dbo',
@source_name   = N'users',
@role_name     = NULL
GO
