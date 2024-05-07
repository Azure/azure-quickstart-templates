#!/bin/bash
#set -xeo pipefail
set -x

# Assuming the first argument is the admin username
export adminUsername="${1//[[:space:]]/}"
export region="${2//[[:space:]]/}"
export resourceId="${3//[[:space:]]/}"
export connectionString="${4//[[:space:]]/}"
export appId="${5//[[:space:]]/}"
export appInsightsResourceId="${6//[[:space:]]/}"

shift 6

# Parameters passed from ARM template
export USEREMAIL="${1//[[:space:]]/}"
export HOSTNAME="${2//[[:space:]]/}"
export TOKEN="${3//[[:space:]]/}"
export INSTALL_DOC_VIEWER="${4//[[:space:]]/}"
export UNDERSTANDING="${5//[[:space:]]/}"

# Function to determine the Linux Distribution
get_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$ID"
  else
    echo "Distribution not supported" >&2
    exit 1
  fi
}

# Function to add a user non-interactively
add_user() {
  local username=$1
  local distro=$(get_distro)

  case $distro in
    debian|ubuntu|linuxmint|pop|elementary|kali|mx|mxlinux|zorinos)
      adduser --gecos "" --disabled-password "$username"
      ;;
    centos|fedora|rhel|redhatenterpriseserver|almalinux|rocky|ol|oraclelinux|scientific|amzn)
      adduser "$username"
      passwd -d "$username"
      ;;
    *)
      echo "Unsupported distribution: $distro" >&2
      return 1
      ;;
  esac
}

# Check if essential fields are present
if [ -z "$HOSTNAME" ] || [ -z "$USEREMAIL" ]; then
  echo "Both 'HOSTNAME' and 'USEREMAIL' are required to proceed." >&2
  exit 1
fi

# Update and install git non-interactively
distro=$(get_distro)
case $distro in
  debian|ubuntu|linuxmint|pop|elementary|kali|mx|mxlinux|zorinos)
    export DEBIAN_FRONTEND=noninteractive
    apt-get update && apt-get -y upgrade
    apt-get install -y git
    ;;
  centos|fedora|rhel|redhatenterpriseserver|almalinux|rocky|ol|oraclelinux|scientific|amzn)
    # the following line (exclude) is necessary at least on CentOS because otherwise
    # the WA agent has an error when the script it is running tries to update the WA agent. :)
    yum update -y --exclude=WALinuxAgent,WALinuxAgent-udev --skip-broken
    yum install -y git
    ;;
  *)
    echo "Unsupported distribution: $distro"
    exit 1
    ;;
esac

# Create a new user and add to sudoers
export username="pro"
if ! id "$username" &>/dev/null; then
  add_user "$username"
  echo "$username ALL=(ALL) NOPASSWD:ALL" >> "/etc/sudoers.d/${username}"
  chmod 0440 "/etc/sudoers.d/${username}"
fi

# Switch to the new user and run the scripts
function run_heredoc_script() {
  su - "$username" <<BBEOF
    cd "/home/${username}" || cd "\$HOME"
    git clone https://github.com/BrowserBox/BrowserBox.git
    cd BrowserBox
    ./deploy-scripts/wait_for_hostname.sh "$HOSTNAME"
    yes | ./deploy-scripts/global_install.sh "$HOSTNAME" "$USEREMAIL"
    export INSTALL_DOC_VIEWER="$INSTALL_DOC_VIEWER"
    if [[ -z "$TOKEN" ]]; then
      setup_bbpro --port 8080 
    else
      setup_bbpro --port 8080 --token "$TOKEN"
    fi
    bbpro &>/dev/null &

  # Inner script starts after this line
  APT=$(command -v apt-get || command -v apt || command -v dnf || command -v yum || command -v brew)

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
  export HOME="/home/${username}"
  export USER="${username}"
  cd \$HOME
  touch \$HOME/.bashrc
  source \$HOME/.nvm/nvm.sh
  command -v nvm || (curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash)
  source \$HOME/.nvm/nvm.sh
  nvm install v20 # we need v20 for the azure libraries

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
            console.error(\`Exceeded \${MAX_TRIES} checks and no metric. Quitting...\`);
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
BBEOF
  return 0
}

# End of the outer heredoc. Exit with the exit status of the heredoc bash script
export -f run_heredoc_script
if ! test -d "/home/${adminUsername}"; then
  mkdir -p "/home/${adminUsername}"
fi
nohup bash -c 'run_heredoc_script' &>"/home/${adminUsername}/bbinstall.log" &

exit 0
