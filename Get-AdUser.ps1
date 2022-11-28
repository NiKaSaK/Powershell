function Get-AdUser {
    param (
        $user,
        $Domain
    )
    try {
        $domainName = $Domain
        $domainContext = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext("Domain", $domainName)
        $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($domainContext)
        $root = $domain.GetDirectoryEntry()
        $ds = [adsisearcher]$root
        $ds.Filter = "(&(objectCategory=User)(sAMAccountname=$user))"
        $de = $ds.FindOne()
        return $de.Properties
    }
    catch {
        Write-Host "ERROR : $_" -ForegroundColor Red
        return $null
    }

}
