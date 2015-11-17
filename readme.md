# Yeoman.VisualStudio
A NuGet package for integrating [Yeoman](http://yeoman.io/) with VisualStudio.  This package adds a cmdlet to your Package Manager Console called `yeo`.  Invoking this cmdlet starts Yeoman, executes the given command, and adds the created files to your VisualStudio project.

## Prerequisites
- npm is installed and included in your `PATH`
- A yeoman generator is installed globally

## Installation
```powershell
PM> Install-Package Yeoman.VisualStudio
```

## Usage 
To invoke a generator, the syntax is:
```powershell
PM> yeo <generator-name>
```

npm modules can be installed directly from the command-line.  If you would rather install them from the Package Manager Console, you can do this:
```powershell
PM> Install-NpmModule <module-name> [$True] # Install Globally
```

## Configuration
This package adds a file called ```yeo.ignore``` to your VisualStudio project. Each line of the file indicates a directory name. If the Yeoman generator adds a file under any of those directory names, the file will not be added to your VisualStudio project. By default, this file includes ```bower_components``` and ```node_modules```.  If Yeoman adds files to these directories, they will not be added to your project.

## Resources
- Available generators: http://yeoman.io/generators/
- Guide to using Yeoman: http://yeoman.io/learning/index.html
	- Note that you will use the cmdlet `yeo` instead of the command-line script `yo`
