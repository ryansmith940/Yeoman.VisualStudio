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
        private HashSet<string> changedFiles;
        private List<string> filesToAdd;
        private List<string> filesToRemove;
        private FileSystemWatcher watcher;

        public DirectoryWatcher(string directory)
        {
            this.watcher = new FileSystemWatcher(directory)
            {
                IncludeSubdirectories = true
            };

            this.watcher.Created += this.WatcherEventRaised;
            this.watcher.Changed += this.WatcherEventRaised;
            this.watcher.Deleted += this.WatcherEventRaised;
            this.watcher.Renamed += this.WatcherEventRaised;
            this.watcher.Error += this.Watcher_Error;
        }

        private void Watcher_Error(object sender, ErrorEventArgs e)
        {
            throw new Exception("The watcher threw an exception", e.GetException());
        }

        private void WatcherEventRaised(object sender, FileSystemEventArgs e)
        {
            this.changedFiles.Add(e.FullPath);
        }

        public bool IsWatching
        {
            get
            {
                return this.watcher.EnableRaisingEvents;
            }
        }

        public void StartWatching()
        {
            this.changedFiles = new HashSet<string>();
            this.watcher.EnableRaisingEvents = true;
        }

        public void EndWatching()
        {
            this.watcher.EnableRaisingEvents = false;
            this.filesToAdd = new List<string>();
            this.filesToRemove = new List<string>();

            foreach (var changedFile in this.changedFiles)
            {
                if (File.Exists(changedFile))
                {
                    this.filesToAdd.Add(changedFile);
                }
                else
                {
                    this.filesToRemove.Add(changedFile);
                }
            }
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
    }
}
