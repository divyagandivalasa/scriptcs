param($installPath, $toolsPath, $package, $project)

$setPath = Join-Path "$Env:USERPROFILE" -childPath ".nuget"
@("packages", "ScriptCs","1.0.0", "tools" ) | %{ $setPath = Join-Path $setPath $_ }
# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
   }
else
   {
   # We are not running "as Administrator" - so relaunch as administrator
   
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
   Write-Host -NoNewLine "Press any key to continue..."
   # Exit from the current, unelevated, process
   exit
   }
 
# Run your code that needs to be elevated here
Write-Host -NoNewLine "Press any key to continue..."
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

