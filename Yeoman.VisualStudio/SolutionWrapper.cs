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
        public SolutionWrapper(EnvDTE.DTE dte)
        {
            foreach (Project item in dte.Solution.Projects)
            {
                
            }
        }
    }
}
