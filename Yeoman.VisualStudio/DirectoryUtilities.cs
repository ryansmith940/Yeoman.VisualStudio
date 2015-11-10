namespace Yeoman.VisualStudio
{
    using System.Collections.Generic;
    using System.IO;

    public class DirectoryUtilities
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
}
