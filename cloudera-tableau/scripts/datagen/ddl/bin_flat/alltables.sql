create database if not exists ${DB};
use ${DB};

drop table if exists customer;
create table customer
stored as ${FILE}
as select * from ${SOURCE}.customer;

drop table if exists lineitem;
create table lineitem
stored as ${FILE}
as select * from ${SOURCE}.lineitem;

drop table if exists nation;
create table nation
stored as ${FILE}
as select * from ${SOURCE}.nation;

drop table if exists orders;
create table orders
stored as ${FILE}
as select * from ${SOURCE}.orders;

drop table if exists part;
create table part
stored as ${FILE}
as select * from ${SOURCE}.part;

drop table if exists partsupp;
create table partsupp
stored as ${FILE}
as select * from ${SOURCE}.partsupp;

drop table if exists region;
create table region
stored as ${FILE}
as select * from ${SOURCE}.region;

drop table if exists supplier;
create table supplier
stored as ${FILE}
as select * from ${SOURCE}.supplier;

!echo "COMPUTING STATS";

analyze table customer compute statistics for columns;
analyze table lineitem compute statistics for columns;
analyze table nation compute statistics for columns;
analyze table orders compute statistics for columns;
analyze table part compute statistics for columns;
analyze table partsupp compute statistics for columns;
analyze table region compute statistics for columns;
analyze table supplier compute statistics for columns;
