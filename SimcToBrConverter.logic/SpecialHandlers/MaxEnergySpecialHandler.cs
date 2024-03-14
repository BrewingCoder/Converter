using SimcToBrConverter.logic.Utilities;

namespace SimcToBrConverter.logic.SpecialHandlers
{
    internal class MaxEnergySpecialHandler : BaseSpecialHandler
    {
        public override bool CanHandle()
        {
            return ProfileProcessor.CurrentActionLine.SpecialHandling.Contains("max_energy=");
        }

        public override void Handle()
        {
            List<string> specialHandling = SplitSpecialHandling();
            foreach (var entry in specialHandling)
            {
                var maxEnergyValue = entry.Replace("max_energy=", "").Trim();
                if (!string.IsNullOrEmpty(ProfileProcessor.CurrentActionLine.Action) && !string.IsNullOrEmpty(maxEnergyValue))
                {
                    if (maxEnergyValue == "1" && ProfileProcessor.CurrentActionLine.Action == "ferocious_bite")
                        ModifyConditions.Add(ProfileProcessor.CurrentActionLine, "energy>=50");
                }
            }
        }
    }
}
