using EnvDTE;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Yeoman.VisualStudio
{
    public class SolutionWrapper
    {
        public static string[] GetIntermediateDirectories(string basePath, string fullPath)
        {
            Stack<string> directoryStack = new Stack<string>();
            var baseDirInfo = new DirectoryInfo(basePath);
            var fullDirInfo = new DirectoryInfo(fullPath);
            
            var nextDirInfo = fullDirInfo;

            while (nextDirInfo != null && baseDirInfo.FullName != nextDirInfo.FullName)
            {
                directoryStack.Push(nextDirInfo.Name);
                nextDirInfo = nextDirInfo.Parent;
            }
            
            if(nextDirInfo != null)
            {
                return directoryStack.ToArray();
            }
            else
            {
                return null;
            }
        }
    }

    [Microsoft.VisualStudio.TestTools.UnitTesting.TestClass]
    public class SolutionWrapperTest
    {
        [TestMethod]
        public void CanGetNextDirectory()
        {
            string baseDir = @"C:\dir1\dir2\dir3";
            string fullDir = @"C:\dir1\dir2\dir3\file.txt";

            string[] nextDir = SolutionWrapper.GetIntermediateDirectories(baseDir, fullDir);

            ArraysAreEqual(new string[] { "file.txt" }, nextDir);
        }

        private void ArraysAreEqual(string[] expected, string[] actual)
        {
            Assert.AreEqual(expected.Length, actual.Length);
            for (int i = 0; i < expected.Length; i++)
            {
                Assert.AreEqual(expected[i], actual[i]);
            }
        }
    }
}
