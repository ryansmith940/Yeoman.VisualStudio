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

function Run-Command($command)
{
	$cmd = "cmd"
	$arguments = "/c " + $command
	Start-Process $cmd $arguments -Wait
}

function Yo
{
	if(Prepare-Environment)
	{
		$solution = Get-Interface $dte.Solution ([EnvDTE80.Solution2])
		$dte.
		Run-Command("yo")
	}
}

Export-ModuleMember Prepare-Environment
Export-ModuleMember Run-Command
Export-ModuleMember Yo