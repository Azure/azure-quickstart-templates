set hive.exec.dynamic.partition.mode=nonstrict;

DROP TABLE IF EXISTS CustomerFirstLastName; 
CREATE TABLE CustomerFirstLastName (
  last  string,
  first string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

LOAD DATA INPATH '${hiveconf:inputtable}' OVERWRITE INTO TABLE CustomerFirstLastName;

DROP TABLE IF EXISTS CustomerName ; 
create external table CustomerName (  
  name string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
STORED AS TEXTFILE 
LOCATION '${hiveconf:outputtable}';

INSERT INTO TABLE CustomerName
SELECT
  CONCAT(first,' ',last)
  FROM CustomerFirstLastName;
