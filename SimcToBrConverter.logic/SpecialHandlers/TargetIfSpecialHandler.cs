using SimcToBrConverter.logic.ActionLines;
using SimcToBrConverter.logic.Utilities;

namespace SimcToBrConverter.logic.SpecialHandlers
{
    public class TargetIfSpecialHandler : BaseSpecialHandler
    {
        public TargetIfSpecialHandler() : base() { }

        public override bool CanHandle()
        {
            return ProfileProcessor.CurrentActionLine.SpecialHandling.Contains("target_if=");
        }

        public override void Handle()
        {
            List<string> specialHandling = SplitSpecialHandling();

            foreach (var entry in specialHandling)
            {
                if (entry.Contains("target_if="))
                {
                    var targetIfValue = entry["target_if=".Length..].Trim();
                    if (!targetIfValue.Contains("max:") && !targetIfValue.Contains("min:"))
                    {
                        ProfileProcessor.CurrentActionLine.TypeSpecial = ActionType.Loop;
                        ModifyConditions.Add(ProfileProcessor.CurrentActionLine, targetIfValue);
                    }
                    else if (targetIfValue.Contains("max:") || targetIfValue.Contains("min:"))
                    {
                        string maxMin;
                        if (targetIfValue.Contains("max:"))
                        {
                            maxMin = targetIfValue["max:".Length..].Trim();
                            ProfileProcessor.CurrentActionLine.TypeSpecial = ActionType.Max;
                        }
                        else
                        {
                            maxMin = targetIfValue["min:".Length..].Trim();
                            ProfileProcessor.CurrentActionLine.TypeSpecial = ActionType.Min;
                        }
                        ConditionConversionService conditionConversionService = ProfileProcessor.ConditionConversionService;
                        ActionLine specialActionLine = new("",ProfileProcessor.CurrentActionLine.Action,"", "", "", maxMin);
                        (_, _) = conditionConversionService.ConvertCondition(specialActionLine);
                        ProfileProcessor.CurrentActionLine.ConvertedSpecial = specialActionLine.Condition;
                    }
                    else
                    {
                        ProfileProcessor.CurrentActionLine.Comment = $"{ProfileProcessor.CurrentActionLine.Comment}\n    -- TODO: Handle {entry}";
                    }
                }
            }
        }
    }
}
