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

function Initialize-Environment
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
	Invoke-Command $command
}

function Invoke-Command
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
	if(Initialize-Environment)
	{
		Add-Type -Path "$PSScriptRoot\Yeoman.VisualStudio.dll"
		$proj = Get-Project
		$projectDir = Split-Path $proj.FullName
		$dirWatcher = New-Object Yeoman.VisualStudio.DirectoryWatcher $projectDir
		$dirWatcher.StartWatching()

		Invoke-Command "echo cd to `"$projectDir`" & cd `"$projectDir`" && yo" @args

		$dirWatcher.EndWatching()
		$dirWatcher.GetFilesToAdd() | ForEach-Object 
		{
			$fileToAdd = $_ 
			$filename = Split-Path $fileToAdd -Leaf

			$intermediatePaths = [Yeoman.VisualStudio.SolutionWrapper]::GetIntermediateDirectories($projectDir, $fileToAdd)
			$projectItem = $proj
			foreach($itemName in $intermediatePaths)
			{
				if($itemName -eq $filename)
				{
					$projectItem.ProjectItems.AddFromFile($fileToAdd)
				}
				else
				{
					$projectItem = Get-ProjectItem $projectItem $itemName
				}
			}
		}
	}
}

function Get-ProjectItem
{
	param(
		$projectItem,
		$itemName
	)

	$foundItem = $projectItem.ProjectItems | Where-Object -Property Name -EQ $itemName
	if($foundItem)
	{
		$projectItem.ProjectItems.Item($itemName)
	}
	else
	{
		$projectItem.ProjectItems.AddDirectory($itemName)
	}
}

Set-Alias yeo Invoke-Yeoman

Export-ModuleMember Initialize-Environment
Export-ModuleMember Invoke-Command
Export-ModuleMember -Function Invoke-Yeoman -Alias yeo
Export-ModuleMember Get-CommandExists
