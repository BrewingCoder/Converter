using CommandLine;
using SimcToBrConverter.logic;

namespace SimcToBrConverter.cli
{
    internal class Program
    {
        private static void Main(string[] args)
        {
            Parser.Default.ParseArguments<ProcessorOptions>(args)
                .WithParsed(RunProcessor)
                .WithNotParsed(HandleParseErrors);
        }

        private static void RunProcessor(ProcessorOptions options)
        {
            var processor = new ProfileProcessor(options);
            processor.ProcessProfile();
        }

        private static void HandleParseErrors(IEnumerable<Error> errs)
        {
            foreach (var error in errs)
            {
                Console.WriteLine(error.Tag);
            }
        }
    }
}
