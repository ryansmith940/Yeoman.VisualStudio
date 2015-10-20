using EnvDTE;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Yeoman.VisualStudio
{
    public class SolutionWrapper
    {
        public static void ShowItems(EnvDTE.DTE dte)
        {
            foreach (Project project in dte.Solution.Projects)
            {
                foreach (ProjectItem projectItem in project.ProjectItems)
                {
                    for (short i = 0; i < projectItem.FileCount; i++)
                    {
                        Console.WriteLine(projectItem.FileNames[i]);
                    }
                }
            }
        }
    }
}
