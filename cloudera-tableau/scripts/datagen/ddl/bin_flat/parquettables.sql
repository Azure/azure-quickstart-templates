invalidate metadata;

create database if not exists tpch_parquet;

drop table if exists tpch_parquet.customer;
create table tpch_parquet.customer
stored as parquet
as select * from tpch_text_2.customer;

drop table if exists tpch_parquet.lineitem;
create table tpch_parquet.lineitem
stored as parquet
as select * from tpch_text_2.lineitem;

drop table if exists tpch_parquet.nation;
create table tpch_parquet.nation
stored as parquet
as select * from tpch_text_2.nation;

drop table if exists tpch_parquet.orders;
create table tpch_parquet.orders
stored as parquet
as select * from tpch_text_2.orders;

drop table if exists tpch_parquet.part;
create table tpch_parquet.part
stored as parquet
as select * from tpch_text_2.part;

drop table if exists tpch_parquet.partsupp;
create table tpch_parquet.partsupp
stored as parquet
as select * from tpch_text_2.partsupp;

drop table if exists tpch_parquet.region;
create table tpch_parquet.region
stored as parquet
as select * from tpch_text_2.region;

drop table if exists tpch_parquet.supplier;
create table tpch_parquet.supplier
stored as parquet
as select * from tpch_text_2.supplier;

compute stats tpch_parquet.customer;
compute stats tpch_parquet.lineitem;
compute stats tpch_parquet.nation;
compute stats tpch_parquet.orders;
compute stats tpch_parquet.part;
compute stats tpch_parquet.partsupp;
compute stats tpch_parquet.region;
compute stats tpch_parquet.supplier;

invalidate metadata;
