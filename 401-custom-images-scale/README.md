TODO
====
download and upload cutting don't work with directories in containers; fix
Use protected settings for keys
blobxfer throws warnings about missing SSL context; fix
Fix naming (e.g. final_vms.json baseTemplateUri isn't a full uri; it's a part of one')



Remove commented-out lines from scripts

vmname/extensions, not extensions/vmname



ERRORS
======
listKeys appears to not respect dependsOn
when reference script uri that doesn't exist, we get "segment length is wrong", which is bad error message -> solved by putting vmname in extension name
'line 1, column 5211' isn't a useful thing, but it also doesn't put you at the right place anyway (do substitutions happen before counting?)
dependsOn doesn't work for script extensions; says "does not exist in template"