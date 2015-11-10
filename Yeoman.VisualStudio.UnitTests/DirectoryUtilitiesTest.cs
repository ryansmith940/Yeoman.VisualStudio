namespace Yeoman.VisualStudio.UnitTests
{
    using Microsoft.VisualStudio.TestTools.UnitTesting;

    [TestClass]
    public class DirectoryUtilitiesTest
    {
        [TestMethod]
        public void CanGetNextDirectory()
        {
            string baseDir = @"C:\dir1\dir2\dir3";
            string fullDir = @"C:\dir1\dir2\dir3\file.txt";

            string[] nextDir = DirectoryUtilities.GetIntermediateDirectories(baseDir, fullDir);

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
