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

function Get-IgnoredDirectories
{
	$proj = Get-Project
	$ignoreFileName = "ignore.properties"
	$ignoreFileExists = Get-ItemInProject $proj $ignoreFileName
	if($ignoreFileExists)
	{
		$projectFullPath = $proj.Properties.Item("FullPath").Value
		$ignoreFileFullPath = Join-Path $projectItemFullPath $ignoreFileName

		Get-Content $ignoreFileFullPath
	}
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

		Write-Host "Starting yeoman..."
		Invoke-Command "echo cd to `"$projectDir`" & cd `"$projectDir`" && yo" @args
		Write-Host "Adding files to project..."

		$dirWatcher.EndWatching()
		$filesToAdd = $dirWatcher.GetFilesToAdd() 
		foreach($fileToAdd in $filesToAdd)
		{
			$filename = Split-Path $fileToAdd -Leaf

			$intermediatePaths = [Yeoman.VisualStudio.SolutionWrapper]::GetIntermediateDirectories($projectDir, $fileToAdd)
			$projectItem = $proj
			$ignoredDirectories = Get-IgnoredDirectories
			foreach($itemName in $intermediatePaths)
			{
				$itemIsInProject = Get-ItemInProject $projectItem $itemName
				if(-Not ($itemIsInProject))
				{
					if($itemName -eq $filename)
					{
				 		$addedFileProjectItem = $projectItem.ProjectItems.AddFromFile($fileToAdd)
					}
					elif($ignoredDirectories -notcontains $itemName)
					{
						$projectItemFullPath = $projectItem.Properties.Item("FullPath").Value
						$folderFullPath = Join-Path $projectItemFullPath $itemName
						$addedDirectoryItems = $projectItem.ProjectItems.AddFromDirectory($folderFullPath)
					}
					else
					{
						continue
					}
				}
				
				$projectItem = $projectItem.ProjectItems.Item($itemName)
			}
		}

		$proj.Save()
		Write-Host "Done!"
	}
}

function Get-ItemInProject
{
	param(
		$projectItem,
		$itemName
	)

	$foundItem = $projectItem.ProjectItems | Where-Object -Property Name -EQ $itemName
	return $foundItem
}

Set-Alias yeo Invoke-Yeoman

Export-ModuleMember Initialize-Environment
Export-ModuleMember Invoke-Command
Export-ModuleMember -Function Invoke-Yeoman -Alias yeo
Export-ModuleMember Get-CommandExists