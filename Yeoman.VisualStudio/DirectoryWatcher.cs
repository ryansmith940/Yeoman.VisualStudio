using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Yeoman.VisualStudio
{
    public class DirectoryWatcher
    {
        private string[] filesAtStart;
        private string[] filesAtEnd;
        private IEnumerable<string> filesToAdd;
        private IEnumerable<string> filesToRemove;
        private string watchedDirectory;

        public DirectoryWatcher(string directory)
        {
            this.watchedDirectory = directory;
        }

        public bool IsWatching
        {
            get;
            private set;
        }

        public void StartWatching()
        {
            this.filesAtStart = GetFilesInDirectory(this.watchedDirectory);
            this.IsWatching = true;
        }

        public void EndWatching()
        {
            this.filesAtEnd = GetFilesInDirectory(this.watchedDirectory);
            this.IsWatching = false;

            this.filesToRemove = this.filesAtStart.Except(this.filesAtEnd);
            this.filesToAdd = this.filesAtEnd.Except(this.filesAtStart);
        }

        public IEnumerable<string> GetFilesToAdd()
        {
            if (this.IsWatching)
            {
                throw new Exception("You must call EndWatching() first.");
            }

            return this.filesToAdd.AsEnumerable<string>();
        }

        public IEnumerable<string> GetFilesToRemove()
        {
            if (this.IsWatching)
            {
                throw new Exception("You must call EndWatching() first.");
            }

            return this.filesToRemove.AsEnumerable<string>();
        }

        private static string[] GetFilesInDirectory(string directory)
        {
            var files = Directory.GetFiles(directory, "*", SearchOption.AllDirectories);
            return files;
        }
    }
}
