create database if not exists ${DB};
use ${DB};

drop table if exists orders;

create table orders
stored as ${FILE}
as select * from ${SOURCE}.orders;
