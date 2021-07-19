<#
    .Synopsis
        
        Exports templates from the Microsoft.Gallery in the Azure Portal to a file or templateSpec resource

    .Description

        This script will export all gallery items (i.e. ARM Templates) available to the current user context.  These templates are available under the
        Microsoft.Gallery Resource Provider or the Azure Portal at:

        https://portal.azure.com/#blade/HubsExtension/BrowseResourceBlade/resourceType/Microsoft.Gallery%2Fmyareas%2Fgalleryitems

        Exporting the gallery items does not remove them from the gallery.  Templates can be saved to an ARM Template file that will create a templateSpec
        for the template, or the templateSpec may be created without saving to a file.  RoleAssignments can optionally be migrated to the templateSpec
        so users that have access to the galleryItem will also have access to the templateSpecs.

    .Notes

        When exporting AllGalleryItems, specifically for items in galleries not owned by the current user context, note the following:

         - Naming collisions can occur when creating templateSpecs since all templateSpecs will reside in the same resourceGroup.  A single attempt
           will be made to change the name to avoid the collision using the origin galleryName, which is the objectId of the owner of the gallery.
        
         - The current context may not have permission to query roleAssignments for shared items, i.e. items not in the gallery owned by the user,
           and if so, roleAssignments will not be migrated for those items.

        The script does not have an option to export the galleryItem as an ARM Template (only a templateSpec) but the template object is available
        in the $templateJSON variable.

        If there are a large number of items in the gallery, the API response will be paged - this script does not follow the link to the next page so
        will only export from the first page.

        Currently when templateSpecs are created from the script, the sort order of the template properties is changed by conversion to json so the source
        code in the resource itself may not look familiar.  To work around this, export the galleryItems to a file and manually deploy the templateSpecs
        from that file.  The azuredeploy.parameters.json file created by this script can be used with azuredeploy.json to deploy all exported templates.

    .Example

    > .\Migrate-GalleryItems.ps1 -ItemsToExport AllGalleryItems -ExportToFile -MigrateRBAC -ResourceGroupName TemplateGalleryTemplates -Location westeurope

#>

param(
    # Specifies the set of templates to export, either items in the current user's gallery or all items the user has access to across the tenant
    [ValidateSet('MyGalleryItems', 'AllGalleryItems')]
    [string] $ItemsToExport = 'MyGalleryItems',

    # The remaing parameters below determine what to do with the the templates in the gallery, if all parameters are ommitted, there will be no output from this script

    # Specifies whether create ARM Templates that create a templateSpec for each template in the gallery
    [switch] $ExportToFile,

    # Determines whether to set permissions on the templateSpecs that are created during export and/or add roleAssignments to the ARM template (when $ExportToFile is specified)
    [switch] $MigrateRBAC,

    # Name of the resourceGroup for the templateSpecs to be created in - if supplied this implies templateSpecs will be created and the location param must also be supplied
    [string] $ResourceGroupName,

    # location of the templateSpec resources, required for creating of templateSpecs (when ResourceGroupName is also specified)
    [string] $Location

)

if ($ResourceGroupName -ne "" -and $location -eq "") {
    Write-Error -Message "Location is required when a the ResourceGroupName is specified."
}

try {
    [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent("AzureQuickStarts-GalleryMigration", "1.0")
} catch { }

if ($ItemsToExport -eq 'MyGalleryItems') {

    # Query for the gallery name, this should be the user's objectId - it's really slow for some reason
    Write-Host "GET galleryName..."
    $r = Invoke-AzRestMethod -Method GET -path "/providers/Microsoft.Gallery/myareas?api-version=2016-03-01-preview"
    $galleryName = ($r.Content | ConvertFrom-Json).value[0].name

    # Query for items in the gallery
    Write-Host "GET all galleryItems in myArea: $galleryName..."
    $r = Invoke-AzRestMethod -Method GET -path "/providers/Microsoft.Gallery/myareas/$galleryName/galleryItems?api-version=2016-03-01-preview"
    $templates = ($r.content | ConvertFrom-Json -Depth 50).Value  

}
else {

    # querying galleryItems will return everything the current user context has access to (i.e. shared with the current user) - not just templates in myArea
    Write-Host "GET all galleryItems accessible by current user context..."
    $r = Invoke-AzRestMethod -Method GET -path "/providers/Microsoft.Gallery/galleryItems?api-version=2016-03-01-preview"
    $items = ($r.Content | ConvertFrom-Json).Value

    $templates = @()
    # When returning all items in the gallery, the response is different - the uri/details are not included and need to be fetched individually
    foreach ($i in $items) {
        $path = "$($i.id)?api-version=2016-03-01-preview"
        Write-Host "GET template content for $($i.name)..."
        $t = Invoke-AzRestMethod -Method GET -Path $path
        $templates += $t.Content | ConvertFrom-Json -Depth 50
    }
}

# template content is stored in the marketplace gallery, not in the ARM control plane, so we need to use Invoke-WebRequest with authn header
$headers = @{
    Authorization = "Bearer $($(Get-AzAccessToken).Token)"
}

# keep a list of the templateSpec names to handle collisions - which can occur when exporting all galleryItems, not just those in the user's gallery
$templateSpecNames = @()
$allTemplateFiles = @()
$templateSpecFileParam = @()

foreach ($t in $templates) {
    
    Write-Host "Processing template $($t.name)..."
    $uri = $t.properties.artifacts.default.uri
    $id = $t.id

    $tsName = $t.name

    # check to see if this name already exists from another gallery, if it does append some of the guid to it and call it good
    if ($templateSpecNames -contains $tsName) {
        $tsName = "$($t.name)-$($galleryName.Substring(8))"
        Write-Host "Changed name to $tsName..."
    }
    $templateSpecNames += $tsName # add the final name to the array used to check for collisions

    # fetch the template content from the gallery 
    Write-Host "Downloading template from: $uri"
    $r = (Invoke-WebRequest -Uri $uri -Method "GET" -Headers $headers -UseBasicParsing -ContentType "application/json")
    $templateJSON = $r.content

    # To create a templateSpec in a template we need to escape expressions e.g. "[variables()]" must be "[[variables()]"
    # if you want the template exported unmodified remove the ::Replace lines below
    $templateJSON = @([Regex]::Replace($templateJSON, '\:\s{0,}\"\s{0,}\[', ': "[[')) # replace expressions in string property types (preceded by a colon ':' )
    $templateJSON = @([Regex]::Replace($templateJSON, '\[\s{0,}\"\s{0,}\[', '[ "[[')) # replace expressions in array properties - the first element of the array (preceded by open bracket '[' )
    $templateJSON = @([Regex]::Replace($templateJSON, '\,\s{0,}\"\s{0,}\[', ', "[[')) # replace expressions in array properties - all elements after the first (preceded by comma ',' )
    
    $templateJSON = $templateJSON | ConvertFrom-Json -Depth 50 #-AsHashtable # convert to a ps object
    
    # create the templateSpec template resources
    $resources = @()
    $templateSpecResource = [ordered]@{
        type       = "Microsoft.Resources/templateSpecs"
        apiVersion = "2019-06-01-preview"
        name       = $tsName
        location   = "[parameters('location')]"
        tags       = [ordered]@{
            publisherName        = $t.properties.publisherName
            publisherDisplayName = $t.properties.publisherDisplayName
            version              = $t.properties.version
            changedTime          = $t.properties.changedTime
            memo                 = "Imported from gallery item $id"
            sourceResourceId     = $id
        }
        properties = [ordered]@{
            description = $t.properties.description
            displayName = $t.properties.displayName
        }
        resources  = @(
            [ordered]@{
                type       = "versions"
                apiVersion = "2019-06-01-preview"
                name       = $t.properties.version # use the version from the galleryItem
                location   = "[parameters('location')]"
                dependsOn  = @($tsName)
                tags       = [ordered]@{
                    publisherName        = $t.properties.publisherName
                    publisherDisplayName = $t.properties.publisherDisplayName
                    version              = $t.properties.version
                    changedTime          = $t.properties.changedTime
                    memo                 = "Imported from gallery item $id"
                    sourceResourceId     = $id
                }
                properties = [ordered]@{
                    description = $t.properties.description
                    template    = $templateJSON
                }
            }
        )
    }
    $resources += $templateSpecResource

    # create roleAssignment Resources if requested
    if ($MigrateRBAC) {
        
        Write-Host "GET roleAssignments for $id"

        $roleAssignments = Get-AzRoleAssignment -Scope $id

        foreach ($ra in $roleAssignments) {
        
            # filter out scopes that don't match the gallery item, scope propery returns higher level assignments in this case tenant assignments        
            if ($ra.scope -eq $id) {
                $roleAssignmentResource = [ordered]@{
                    scope      = "Microsoft.Resources/templateSpecs/$($tsName)"
                    type       = "Microsoft.Authorization/roleAssignments"
                    apiVersion = "2020-04-01-preview"
                    name       = "[guid(resourceId('Microsoft.Resources/templateSpecs', '$tsName'), '$($ra.RoleDefinitionId)', '$($ra.ObjectId)')]"
                    dependsOn  = @( $tsName )
                    tags       = [ordered]@{
                        memo              = "Migrated from $($ra.scope)"
                        sourceResourceId  = $ra.RoleAssignmentId
                        signInName        = $ra.SignInName
                        roleDefintionName = $ra.RoleDefinitionName
                    }
                    properties = [ordered]@{
                        principalId      = $ra.ObjectId
                        roleDefinitionId = "[resourceId('Microsoft.Authorization/roleDefinitions', '$($ra.RoleDefinitionId)')]"
                        principalType    = $ra.ObjectType
                    }
                }
                $resources += $roleAssignmentResource
            }
        }
    } # if migrate RBAC

    $templateFile = [ordered]@{
        '$schema'      = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
        contentVersion = "1.0.0.0"
        parameters     = [ordered]@{
            location = [ordered]@{
                type         = 'string'
                defaultValue = '[resourceGroup().location]'
            }
        }
        resources      = $resources
    }

    # add this file to the collection of all template so we can loop deployment on the templates if requested
    $allTemplateFiles += $templateFile

    # Export templates to a file on disk
    if ($ExportToFile) {
        $galleryFolder = $id.split('/')[4]
        # Create the folder if it doesn't exist
        if (!(Test-Path -path $galleryFolder)) {
            Write-Host "Creating folder: $galleryFolder..."
            New-Item -ItemType Directory -Path $galleryFolder -Verbose
        }
        Write-Host "Creating ARM Template for: $tsName"
        $templateFile | ConvertTo-Json -Depth 50 | Set-Content -Path "$galleryFolder/$($tsName).json"

        $templateSpecFileParam += "$galleryFolder/$($tsName).json" # add this file to the parameter file that will deploy all templateSpecs

    } # if ExportToFile

} # foreach template

# Write the parameter file for azuredeploy.json that will deploy all of the exported templates
if ($ExportToFile) {

    $paramFile = [ordered]@{
        '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
        contentVersion = "1.0.0.0"
        parameters = @{
            templateSpecFiles = @{
                value = $templateSpecFileParam
            }
        }
    }

    Write-Host "Creating ARM Template parameter file..."
    $paramFile | ConvertTo-Json -Depth 10 | Set-Content -Path "azuredeploy.parameters.json"

} # if ExportToFile for the Parameters File

# create templateSepcs if a resourceGroupName is specified
if ($ResourceGroupName -ne "") {

    # check for the resourceGroup - if it doesn't exist create it and set roleAssignments when RBAC is migrated   
    if ($null -eq (Get-AzResourceGroup -Name $ResourceGroupName -Location $Location -Verbose -ErrorAction SilentlyContinue)) {
        New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Verbose -Force -ErrorAction Stop
    }
    
    # migrate any roleAssignments that exist on the gallery itself 
    if ($MigrateRBAC) {
        Write-Host "Checking for roleAssignments on the gallery..."
        $galleryId = "/providers/Microsoft.Gallery/myareas/$galleryName"
                    
        $roleAssignments = Get-AzRoleAssignment -Scope $galleryId
                    
        foreach ($ra in $roleAssignments) {
            # only migrate if the assignment is at the galleryScope, not above
            if ($ra.Scope -eq $galleryId) {
                $s = "/subscriptions/$($(Get-AzContext).Subscription.id)/resourceGroups/$ResourceGroupName"
                $existingRoleAssignment = Get-AzRoleAssignment -Scope $s -ObjectId $ra.ObjectId -RoleDefinitionId $ra.RoleDefinitionId # check for an existing assignment (under another name)
                if ($null -eq $existingRoleAssignment) {
                    Write-Host "Adding roleAssignment for principal: $($ra.ObjectId)"
                    New-AzRoleAssignment -scope $s -ObjectId $ra.ObjectId -RoleDefinitionId $ra.RoleDefinitionId -Verbose
                }
                else {
                    Write-Host "RoleAssignment exists for:`nScope: $s`nPrincipal: $($ra.ObjectId)`nRole: $($ra.RoleDefinitionName)`n"
                }
            }
        }
    }

    # Deploy the templates from memory since they may not be written to file
    foreach ($t in $allTemplateFiles) {
        $t = $t | ConvertTo-Json -depth 50 | ConvertFrom-Json -Depth 50 -AsHashtable # this is needed to overcome a limitation in deploying a templateObject that contains a PSCustomObject - removing that PSCustomObject changes the sort order of the properties in the inline template
        New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateObject $t -Verbose
    }

} # resourceGroupName -ne "" - Create TemplateSpecs

