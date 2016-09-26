param($installPath, $toolsPath, $package, $project)
$setPath = Join-Path "$Env:USERPROFILE" -childPath ".nuget"
@("packages", "ScriptCs","1.0.0", "tools" ) | %{ $setPath = Join-Path $setPath $_ }
if ( -not ( [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole( [Security.Principal.WindowsBuiltInRole] "Administrator") )
 {
    $scriptpath = $MyInvocation.MyCommand.Definition
    $scriptpaths = "'$scriptPath'"
    Start-Process -FilePath PowerShell.exe  -Verb runAs -ArgumentList "& $scriptpaths"
 }
 else
 {
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
 }
# Run your code that needs to be elevated here
Write-Host -NoNewLine "Press any key to continue... Install"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

function Set-EnvPath {
    param(
        [Parameter(Mandatory=$true)]
        $Path
    )
		$write = Read-Host 'Set PATH permanently ? (yes|no)'
		$persistedPaths = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine) -split ';'
		if ($write -eq "yes")
		{	
			if ($persistedPaths -notContains $Path) 
			{
				$persistedPaths = $persistedPaths + $Path | where { $_ }
				[Environment]::SetEnvironmentVariable('Path', $persistedPaths -Join';', [System.EnvironmentVariableTarget]::Machine)
			}
			$envPaths = $env:Path -split ';'
			if ($envPaths -notcontains $Path) 
			{
			    $envPaths = $envPaths + $Path | where { $_ }
			    $env:Path = $envPaths -Join ';'
			}
		    Write-Output 'PATH updated'
		}               
}
Set-EnvPath "$setPath"