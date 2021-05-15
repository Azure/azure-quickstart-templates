set hive.exec.dynamic.partition.mode=nonstrict;

DROP TABLE IF EXISTS WebLogsRaw; 
CREATE TABLE WebLogsRaw (
  date  date,
  time  string,
  ssitename string,
  csmethod  string,
  csuristem  string,
  csuriquery string,
  sport int,
  susername string,
  cipcsUserAgent string,
  csCookie string,
  csReferer string,
  cshost  string,
  scstatus  int,
  scsubstatus  int,
  scwin32status  int,
  scbytes int,
  csbytes int,
  timetaken int
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ' '
LINES TERMINATED BY '\n' 
tblproperties ("skip.header.line.count"="2");

LOAD DATA INPATH '${hiveconf:inputtable}' OVERWRITE INTO TABLE WebLogsRaw;

DROP TABLE IF EXISTS WebLogsPartitioned ; 
create external table WebLogsPartitioned (  
  date  date,
  time  string,
  ssitename string,
  csmethod  string,
  csuristem  string,
  csuriquery string,
  sport int,
  susername string,
  cipcsUserAgent string,
  csCookie string,
  csReferer string,
  cshost  string,
  scstatus  int,
  scsubstatus  int,
  scwin32status  int,
  scbytes int,
  csbytes int,
  timetaken int
)
partitioned by ( year int, month int)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
STORED AS TEXTFILE 
LOCATION '${hiveconf:partitionedtable}';

INSERT INTO TABLE WebLogsPartitioned  PARTITION( year , month) 
SELECT
  date,
  time,
  ssitename,
  csmethod,
  csuristem,
  csuriquery,
  sport,
  susername,
  cipcsUserAgent,
  csCookie,
  csReferer,
  cshost,
  scstatus,
  scsubstatus,
  scwin32status,
  scbytes,
  csbytes,
  timetaken,
  year(date),
  month(date)
FROM WebLogsRaw