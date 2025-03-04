#!/usr/bin/env bash

adminUsername=$1  # Assuming the first argument is the admin username
region="${2//[[:space:]]/}"
resourceId="${3//[[:space:]]/}"
connectionString="${4//[[:space:]]/}"
appId="${5//[[:space:]]/}"
appInsightsResourceId="${6//[[:space:]]/}"

# Outer heredoc starts here
sudo -u "$adminUsername" bash -s "$region" "$resourceId" "$connectionString" "$appId" "$appInsightsResourceId" <<'EOF'
# Inner script starts after this line
APT=$(command -v apt-get || command -v apt || command -v dnf || command -v yum || command -v brew)

# Parameters received from outer script
region="$1"
resourceId="$2"
connectionString="$3"
appId="$4"
appInsightsResourceId="$5"

# Logging
echo "Region: [$region]"
echo "ResourceID: [$resourceId]"
echo "ConnectionString: [$connectionString]"
echo "AppInsights App ID: [$appId]"
echo "AppInsights Resource ID: [$appInsightsResourceId]"

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_SUSPEND=1
export NEEDRESTART_MODE=a

# Install jq if not present
command -v jq &>/dev/null || sudo $APT install -y jq

sleep 5

# Install Node.js using nvm
cd $HOME
touch $HOME/.bashrc
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source $HOME/.nvm/nvm.sh
nvm install v22 # we need v22 for the azure libraries

# Create and navigate to the application directory
mkdir test-app
cd test-app

# Initialize a new Node.js project
npm init -y

# Install Application Insights
npm i --save applicationinsights @azure/identity @azure/monitor-query bluebird

# Export the connection string to an environment variable
export APPINSIGHTS_CONNECTION_STRING="$connectionString"
export APPINSIGHTS_APP_ID="$appId"
export APPINSIGHTS_RESOURCE_ID="$appInsightsResourceId"

# Create a Node.js script using a heredoc
cat << 'INNER_EOF' > app.js
const appInsights = require('applicationinsights');
const { DefaultAzureCredential } = require('@azure/identity');
const { Durations, MetricsQueryClient, LogsQueryClient } = require('@azure/monitor-query');
console.log({LogsQueryClient});
const { delay } = require('bluebird');

appInsights.setup(process.env.APPINSIGHTS_CONNECTION_STRING).setSendLiveMetrics(true).start();

const client = appInsights.defaultClient;

// Example URL for the login link
const loginLinkUrl = "https://example.com/login?token=abc123";

// Sending a custom event and metric
client.trackMetric({
  name: "LoginLink",
  value: 1,
  properties: { url: loginLinkUrl }  // Additional data
});
setTimeout(() => {
  client.trackMetric({
    name: "LoginLink",
    value: 1,
    properties: { url: loginLinkUrl }  // Additional data
  });
}, 30000);
setTimeout(() => {
  client.trackMetric({
    name: "LoginLink",
    value: 1,
    properties: { url: loginLinkUrl }  // Additional data
  });
}, 60000);
setTimeout(() => {
  client.trackMetric({
    name: "LoginLink",
    value: 1,
    properties: { url: loginLinkUrl }  // Additional data
  });
}, 90000);

console.log('Custom event sent to Application Insights');

// Function to check metric availability
async function checkMetricAvailability() {
  const credential = new DefaultAzureCredential();
  const monitorQueryClient = new MetricsQueryClient(credential);
  const appId = process.env.APPINSIGHTS_APP_ID; // Set this environment variable to your Application Insights App ID
  const appInsightsResourceId = process.env.APPINSIGHTS_RESOURCE_ID;
  const MAX_TRIES = 150; // around about 12 and a half minutes
  let tries = 0;
  let code = 0;

  waitMetric: while (true) {
    tries++;
    try {
      const iterator = await monitorQueryClient.listMetricDefinitions(appInsightsResourceId, {metricNamespace: "azure.applicationinsights"});
      for await ( const result of iterator ) {
        if(result.name == "LoginLink") {
	  console.log('Metric is available.');
	  break waitMetric;
        }
      }
        console.log('Metric not available yet, retrying in 5 seconds...');
        if ( (tries % 5) == 0 ) {
          console.log('5 checks without metric. Resending it...');
          client.trackMetric({
            name: "LoginLink",
            value: 1,
            properties: { url: loginLinkUrl }  // Additional data
          });
        } else if ( tries > MAX_TRIES ) {
          console.error(`Exceeded ${MAX_TRIES} checks and no metric. Quitting...`);
          code = 1;
          break;
        }
        await delay(5000);
    } catch (error) {
      console.error('Error querying Application Insights:', error);
      tries += 30; // penalize an error try
      await delay(5000); // Retry after delay even in case of error
    }
  }

  console.log('Exiting...');
  process.exit(code);
}

// Call the function
//checkMetricAvailability();
INNER_EOF

# Run the Node.js script
(node app.js &>/dev/null &) || (echo "Node had an error" >&2 && exit 1)
exit 0

# End of the inner script
EOF
# End of the outer heredoc. Exit with the exit status of the heredoc bash script

exit $?


