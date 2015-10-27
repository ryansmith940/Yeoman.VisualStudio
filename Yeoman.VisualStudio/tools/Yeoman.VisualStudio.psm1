function Get-CommandExists($commandName)
{
	Try
	{
		$oldPreference = $ErrorActionPreference
		$ErrorActionPreference = 'stop'

		$knownCommands = Get-Command $commandName
	    return $True
	}
	Catch
	{
		return $False
	}
	Finally
	{
		$ErrorActionPreference = $oldPreference
	}
}

function Prepare-Environment
{
	if (-Not (Get-CommandExists node))
	{
		Write-Error "\"node\" is not available.  You will need to install it from https://nodejs.org/ and/or add it to your PATH."
		return $False
	}

	if (-Not (Get-CommandExists npm))
	{
		Write-Error "\"npm\" is not available.  You will need to install it from https://nodejs.org/ and/or add it to your PATH."
		return $False
	}

	if (-Not (Get-CommandExists yo))
	{
		Write-Warning "Yeoman is not installed.  Installing it now..."
		Install-NpmModule "yo" $True
	}

	return $True
}

function Install-NpmModule($moduleName, $globally)
{
	$command = "npm install " + @{$true="-g ";$false=" "}[$globally] + $moduleName
	Run-Command $command
}

function Run-Command
{
	param(
		[string]$command
	)

	$cmd = "cmd"
	$arguments = "/c " + $command + " " + $args + " & pause"
	Start-Process $cmd $arguments -Wait
}

function Invoke-Yeoman
{
	if(Prepare-Environment)
	{
		$solution = Get-Interface $dte.Solution ([EnvDTE80.Solution2])
		#$dte.
		Run-Command "yo" @args
	}
}

function Ed
{
	Add-Type -Path "$PSScriptRoot\Yeoman.VisualStudio.dll"
	$proj = Get-Project
	$projectDir = Split-Path $proj.FullName
	$dirWatcher = New-Object Yeoman.VisualStudio.DirectoryWatcher $projectDir
	$dirWatcher.StartWatching()

	Run-Command "echo cd to `"$projectDir`" & cd `"$projectDir`" && yo" @args

	$dirWatcher.EndWatching()
	$dirWatcher.GetFilesToAdd()
}

Export-ModuleMember Prepare-Environment
Export-ModuleMember Run-Command
Export-ModuleMember Invoke-Yeoman
Export-ModuleMember Ed
Export-ModuleMember Get-CommandExists