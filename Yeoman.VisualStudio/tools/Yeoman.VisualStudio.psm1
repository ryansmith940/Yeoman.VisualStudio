Function Command-Exists
{
	Param ($command)
	try
	{
		Get-Command $command
		return true
	}
	Catch
	{
		return false
	}
}