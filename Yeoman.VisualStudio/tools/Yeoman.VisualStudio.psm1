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
			foreach($itemName in $intermediatePaths)
			{
				if($itemName -eq $filename)
				{
				 	$addedFileProjectItem = $projectItem.ProjectItems.AddFromFile($fileToAdd)
				}
				else
				{
					$projectItem
					$projectItem = Add-ProjectFolder $projectItem $itemName
				}
			}
		}

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

function Add-ProjectFolder
{
	param(
		$projectItem,
		$folderName
	)

	$folderInProject = Get-ItemInProject $projectItem $folderName
	if($folderInProject)
	{
		return $projectItem.ProjectItems.Item($folderName)
	}
	else
	{
		$projectItem
		$projectItemFullPath = $projectItem.Properties.Item("FullPath").Value
		$folderFullPath = Join-Path $projectItemFullPath $folderName
		$folderExists = Test-Path $folderFullPath

		if($folderExists)
		{
			# Find unused folder name for temporary storage
			$tempFolderName = "_" + $folderName
			while(Join-Path $projectItemFullPath $tempFolderName | Test-Path)
			{
				$tempFolderName = "_" + $tempFolderName
			}

			# Rename existing folder to temporary name
			$tempFolderFullPath = Join-Path $projectItemFullPath $tempFolderName
			Rename-Item $folderFullPath $tempFolderName

			# re-create the folder
			$folderProjectItem = $projectItem.ProjectItems.AddFolder($folderName)

			# move items from temporary folder into re-created folder and delete temporary folder
		 	$tempContents = Join-Path $tempFolderFullPath "*" 
			Move-Item $tempContents $folderFullPath
			Remove-Item $tempFolderFullPath

			return $folderProjectItem
		}
		else
		{
			return $projectItem.ProjectItems.AddFolder($folderName)
		}
	}
}

Set-Alias yeo Invoke-Yeoman

Export-ModuleMember Initialize-Environment
Export-ModuleMember Invoke-Command
Export-ModuleMember -Function Invoke-Yeoman -Alias yeo
Export-ModuleMember Get-CommandExists
Export-ModuleMember Add-ProjectFolder