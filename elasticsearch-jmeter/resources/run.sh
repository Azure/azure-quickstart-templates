#!/bin/bash
/opt/jmeter/apache-jmeter-2.13/bin/jmeter -n -r -t /opt/jmeter/testplan5nodes.jmx -Grun.properties -Jm1=10.0.1.4 -Jm2=10.0.1.5 -Jm3=10.0.1.6 -Jm4=10.0.1.7 -Jm5=10.0.1.8 -Jreport1=report1 -Jreport2=report2 -Jreport3=report3 -Jreport4=report4 -Jreport5=report5 -Jreport6=report6 -Jreport7=report7 -Jreport8=report8 -Jreport9=report9
