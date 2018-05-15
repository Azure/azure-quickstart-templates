# Ensure that the Base URL for templates, scripts and deploy to Azure buttons
# is correctly set for the current git branch.

# Correct values for locations
CURRENT_BRANCH=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
echo "Current git branch is '$CURRENT_BRANCH'"

BASE_TEMPLATE_URL=https://raw.githubusercontent.com/Azure/Moodle/$CURRENT_BRANCH/nested/
echo "Base template URL: $BASE_TEMPLATE_URL"

SCRIPT_LOCATION=https://raw.githubusercontent.com/Azure/Moodle/$CURRENT_BRANCH/scripts/
echo "Script location: $SCRIPT_LOCATION"

DEPLOY_TO_AZURE_URL=https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FMoodle%2F$CURRENT_BRANCH%2Fazuredeploy.json
echo "Deploy to Azure URL: $DEPLOY_TO_AZURE_URL"

VISUALIZE_URL=http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FMoodle%2F$CURRENT_BRANCH%2Fazuredeploy.json
echo "Visualize template URL: $VISUALIZE_URL"

# Check values in README.md

VALUE=$(sed -n -e 's/.*deploybutton.png)](\([^)]*\)).*/\1/p' README.md)
if [[ "$VALUE" = "$DEPLOY_TO_AZURE_URL" ]]
then
    echo "Deploy to Azure URL is set correctly"
else
    echo "!!!!! Deploy to Azure URL is not set correctly in README.md, it is currently:"
    echo $VALUE
fi

VALUE=$(sed -n -e 's/.*visualizebutton.png)](\([^)]*\)).*/\1/p' README.md)
if [[ "$VALUE" = "$VISUALIZE_URL" ]]
then
    echo "Visualize URL is set correctly"
else
    echo "!!!!! Visualize URL is not set correctly in README.md, it is currently:"
    echo $VALUE
fi

# Check values in azuredeploy.json

VALUE=$(sed -n -e 's/.*\"baseTemplateUrl\": \"\([^\"]*\)\",/\1/p' azuredeploy.json)
if [[ "$VALUE" = "$BASE_TEMPLATE_URL" ]]
then
    echo "baseTemplateURL is set correctly"
else
    echo "!!!!! baseTemplateURL is not set correctly, it is currently:"
    echo $VALUE
fi

VALUE=$(sed -n -e 's/.*\"scriptLocation\": \"\([^\"]*\)\",/\1/p' azuredeploy.json)
if [[ "$VALUE" = "$SCRIPT_LOCATION" ]]
then
    echo "scriptLocation is set correctly"
else
    echo "!!!!! scriptLocation is not set correctly, it is currently:"
    echo $VALUE
fi
