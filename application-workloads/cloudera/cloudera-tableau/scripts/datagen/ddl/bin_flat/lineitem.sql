create database if not exists ${DB};
use ${DB};

drop table if exists lineitem;

create table lineitem
stored as ${FILE}
as select * from ${SOURCE}.lineitem;
