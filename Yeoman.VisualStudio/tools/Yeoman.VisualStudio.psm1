function Get-CommandExists
{
	Write-Host "Hello world"
	Param ($command)
	try
	{
		Get-Command $command
		return true
	}
	catch
	{
		return false
	}
}

Export-ModuleMember Get-CommandExists