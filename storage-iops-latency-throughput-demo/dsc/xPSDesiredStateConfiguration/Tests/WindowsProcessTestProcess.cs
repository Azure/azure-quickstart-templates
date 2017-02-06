using System.IO;
using System.Threading;

// This is a test process used for testing configuring running and stopping a process on a machine
namespace WindowsProcessTestProcess
{
    class Program
    {
        static void Main(string[] args)
        {
            string[] lines = { "Test line1", "Test line2", "Test line3" };

            if (args.Length > 0)
            {
                string filePath = args[0];

                using (StreamWriter outputFile = new StreamWriter(filePath))
                {
                    // Write to a log file so that we can see if the process ran
                    foreach (var line in lines)
                    {
                        outputFile.WriteLine(line);
                    }
                }
            }

            if (args.Length <= 1 || (args.Length > 1 && args[1] != "Stop Running"))
            {
                // Sleep so that the process stays running until it is killed
                Thread.Sleep(Timeout.Infinite);
            }
        }
    }
}

