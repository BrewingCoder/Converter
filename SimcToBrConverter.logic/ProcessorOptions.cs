using CommandLine;

namespace SimcToBrConverter.logic
{
    public class ProcessorOptions : IProcessorOptions
    {
        [Option('i', "in", Required = true, HelpText = "SimC Input file to be processed.")]
        public string? InputFile { get; set; }

        [Option('o', "out", Required = true, HelpText = "Output (LUA) file to be written.")]
        public string? OutputFile { get; set; }

    }
}
