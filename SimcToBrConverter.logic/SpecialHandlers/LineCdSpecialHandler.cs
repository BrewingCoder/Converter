using SimcToBrConverter.logic.Utilities;

namespace SimcToBrConverter.logic.SpecialHandlers
{
    internal class LineCdSpecialHandler : BaseSpecialHandler
    {
        public override bool CanHandle()
        {
            return ProfileProcessor.CurrentActionLine.SpecialHandling.Contains("line_cd");
        }
        int lineCount = 0;

        public override void Handle()
        {

            List<string> specialHandling = SplitSpecialHandling();
            foreach (var entry in specialHandling)
            {
                if (entry.Contains("line_cd="))
                {
                    int lineCdValue = int.Parse(entry.Replace("line_cd=", ""));
                    string actionName = StringUtilities.ConvertToTitleCaseNoSpace(ProfileProcessor.CurrentActionLine.Action);
                    ModifyConditions.Add(ProfileProcessor.CurrentActionLine, $"linecd.{actionName}{lineCount++}.{lineCdValue}");
                }
            }
            
        }
    }
}
