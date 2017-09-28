use ${DB};

!echo "COMPUTING STATS";

analyze table customer compute statistics;
analyze table lineitem compute statistics;
analyze table nation compute statistics;
analyze table orders compute statistics;
analyze table part compute statistics;
analyze table partsupp compute statistics;
analyze table region compute statistics;
analyze table supplier compute statistics;

analyze table customer compute statistics for columns;
analyze table lineitem compute statistics for columns;
analyze table nation compute statistics for columns;
analyze table orders compute statistics for columns;
analyze table part compute statistics for columns;
analyze table partsupp compute statistics for columns;
analyze table region compute statistics for columns;
analyze table supplier compute statistics for columns;
