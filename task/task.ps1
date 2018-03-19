[CmdletBinding()]
param()

function GetVersionNumber($versionString)
{
    if($versionString)
    {
        $VersionData = [Regex]::Matches($versionString, "\d+\.\d+\.?\d*\.?\d*")

        if ($VersionData.Count -eq 0)
        {
            throw "Could not find version number data in '$versionString'."
        }

        if ($VersionData.Count -ne 1)
        {
            Write-Warning "Found more than instance of version data in '$versionString'." 
            Write-Warning "Will assume first instance is version."   
        }

        return $VersionData;
    }
    
    throw "Version number is not specified."
}

Trace-VstsEnteringInvocation $MyInvocation

try 
{
    # Set the working directory.
    $cwd = Get-VstsInput -Name cwd -Require
    Assert-VstsPath -LiteralPath $cwd -PathType Container
    Write-Verbose "Setting working directory to '$cwd'."
    Set-Location $cwd

    foreach ($file in $files)
    {
        # remove the read-only attribute, making the file writable
        attrib $file -r

        # get the file contents
        $xml = [xml](Get-Content($file))

        $node = $xml.PackageManifest.Metadata.Identity
        $node.Version = [string]$version

        $xml.Save($file)
    }
    # Output the message to the log.
    Write-Host (Get-VstsInput -Name msg)
} finally
{
    Trace-VstsLeavingInvocation $MyInvocation
}
