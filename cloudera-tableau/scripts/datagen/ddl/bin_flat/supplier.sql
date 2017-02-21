create database if not exists ${DB};
use ${DB};

drop table if exists supplier;

create table supplier
stored as ${FILE}
as select * from ${SOURCE}.supplier;
