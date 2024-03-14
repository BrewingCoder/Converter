using System.Text.RegularExpressions;
using SimcToBrConverter.logic.Utilities;

namespace SimcToBrConverter.logic.ActionHandlers
{
    public class UseItemActionHandler : BaseActionHandler
    {
        public override bool CanHandle()
        {
            return ProfileProcessor.CurrentActionLine.Action.Contains("use_item") ||
                    ProfileProcessor.CurrentActionLine.Action.Contains("use_items") ||
                    ProfileProcessor.CurrentActionLine.Action.Contains("augmentation") ||
                    ProfileProcessor.CurrentActionLine.Action.Contains("flask") ||
                    ProfileProcessor.CurrentActionLine.Action.Contains("potion") ||
                    ProfileProcessor.CurrentActionLine.Action.Contains("food") ||
                    ProfileProcessor.CurrentActionLine.Action.Contains("snapshot_stats");
        }

        public override void Handle()
        {
            if (ProfileProcessor.CurrentActionLine.Action is string s)
            {
                if (s.Contains("use_items") && string.IsNullOrEmpty(ProfileProcessor.CurrentActionLine.Condition))
                {
                    ProfileProcessor.CurrentActionLine.Type = ActionType.Module;
                    ProfileProcessor.CurrentActionLine.Action = "module";
                    ProfileProcessor.Locals.Add("module");
                    ProfileProcessor.CurrentActionLine.SpecialHandling = "name=basic_trinkets";
                }
                else if (s.Contains("flask"))
                {
                    ProfileProcessor.CurrentActionLine.Type = ActionType.Module;
                    ProfileProcessor.CurrentActionLine.Action = "module";
                    ProfileProcessor.Locals.Add("module");
                    ProfileProcessor.CurrentActionLine.SpecialHandling = "name=phial_up";
                }
                else if (s.Contains("augmentation"))
                {
                    ProfileProcessor.CurrentActionLine.Type = ActionType.Module;
                    ProfileProcessor.CurrentActionLine.Action = "module";
                    ProfileProcessor.Locals.Add("module");
                    ProfileProcessor.CurrentActionLine.SpecialHandling = "name=imbue_up";
                }
                else if (s.Contains("potion"))
                {
                    ProfileProcessor.CurrentActionLine.Type = ActionType.Module;
                    ProfileProcessor.CurrentActionLine.Action = "module";
                    ProfileProcessor.Locals.Add("module");
                    ProfileProcessor.CurrentActionLine.SpecialHandling = "name=combatPotion_up";
                }
                else if (s.Contains("potion") || s.Contains("use_item"))
                {
                    ProfileProcessor.CurrentActionLine.Type = ActionType.UseItem;
                    ProfileProcessor.Locals.Add("use");
                }
                else if (s.Contains("food") || s.Contains("snapshot_stats"))
                {
                    ProfileProcessor.CurrentActionLine.Type = ActionType.Ignore;
                }
            }         
            var nameValue = ProfileProcessor.CurrentActionLine.SpecialHandling.Replace("name=", "").Trim().Split(",")[0];
            nameValue = nameValue.Replace("=trinket", "");
            if (ProfileProcessor.CurrentActionLine.SpecialHandling.Contains("slots="))
                ProfileProcessor.CurrentActionLine.Op = nameValue.Replace("slots","");

            // Handle trinket.integer.is case
            string patternIs = @"trinket\.(\d+)\.is\.(\w+)";
            string replacementIs = "equipped.$2.$1";
            ProfileProcessor.CurrentActionLine.Condition = Regex.Replace(ProfileProcessor.CurrentActionLine.Condition, patternIs, replacementIs);

            // Handle trinket.integer.cooldown case
            string patternCooldown = @"trinket\.(\d+)\.cooldown\.(\w+)";
            string replacementCooldown = $"cooldown.slot.$2.$1";
            ProfileProcessor.CurrentActionLine.Condition = Regex.Replace(ProfileProcessor.CurrentActionLine.Condition, patternCooldown, replacementCooldown);

            if (!string.IsNullOrEmpty(ProfileProcessor.CurrentActionLine.Action) && !string.IsNullOrEmpty(nameValue))
            {
                if (ProfileProcessor.CurrentActionLine.SpecialHandling.Contains("slots="))
                    ProfileProcessor.CurrentActionLine.Action = $"{nameValue.Replace(ProfileProcessor.CurrentActionLine.Op,"")}";
                else
                    ProfileProcessor.CurrentActionLine.Action = $"{nameValue}";
            }
            //actionLine.Condition = opValue;
        }
    }
}
