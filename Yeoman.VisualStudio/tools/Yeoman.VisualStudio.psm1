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

function Get-CheckEnvironment
{
	if (-Not (Get-CommandExists node))
	{
		Write-Host "Node not available"
	}

	Write-Error "error"
	Throw ""
	Write-Host "more stuff"
}

Export-ModuleMember Get-CheckEnvironment