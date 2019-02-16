function Expand-AccessLevel
{
    [OutputType([System.String[]])]
    param(
        [Parameter()]
        $Security,

        [Parameter()]
        [System.String[]]
        $AccessLevels
    )

    $expandedAccessLevels = $AccessLevels

    foreach ($namedAccessRight in $Security.NamedAccessRights)
    {
        if ($AccessLevels -contains $namedAccessRight.Name)
        {
            foreach ($namedAccessRight2 in $Security.NamedAccessRights)
            {
                if ($expandedAccessLevels -notcontains $namedAccessRight2.Name -and
                    $namedAccessRight2.Rights.IsSubsetOf($namedAccessRight.Rights))
                {
                    $expandedAccessLevels += $namedAccessRight2.Name
                }
            }
        }
    }
    return $expandedAccessLevels
}
