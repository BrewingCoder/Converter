using SimcToBrConverter.logic.Utilities;

namespace SimcToBrConverter.logic.SpecialHandlers
{
    internal class NameSpecialHandler : BaseSpecialHandler
    {
        public override bool CanHandle()
        {
            return ProfileProcessor.CurrentActionLine.SpecialHandling.Contains("name=");
        }

        public override void Handle()
        {

            List<string> specialHandling = SplitSpecialHandling();

            foreach (var entry in specialHandling)
            {
                if (entry.Contains("name="))
                {
                    var nameValue = entry.Replace("name=", "").Trim();
                    if (!string.IsNullOrEmpty(ProfileProcessor.CurrentActionLine.Action) && !string.IsNullOrEmpty(nameValue))
                    {
                        switch (ProfileProcessor.CurrentActionLine.Type)
                        {
                            case ActionType.Module:
                                ProfileProcessor.Locals.Add("module");
                                break;
                            case ActionType.UseItem:
                                ProfileProcessor.Locals.Add("use");
                                break;
                            case ActionType.Variable:
                                ProfileProcessor.Locals.Add("var");
                                break;
                            case ActionType.Default:
                                if (ProfileProcessor.CurrentActionLine.Action.Contains("variable"))
                                {
                                    ProfileProcessor.Locals.Add("var");
                                    ProfileProcessor.CurrentActionLine.Action = $"var.{nameValue}";
                                    ProfileProcessor.CurrentActionLine.Type = ActionType.Variable;
                                    int ifPos = ProfileProcessor.CurrentActionLine.Condition.IndexOf(",if=");
                                    string value;
                                    string condition;
                                    if (ifPos > 0)
                                    {
                                        value = ProfileProcessor.CurrentActionLine.Condition[..ifPos].Trim();
                                        condition = ProfileProcessor.CurrentActionLine.Condition[(ifPos + 4)..].Trim();
                                        ProfileProcessor.CurrentActionLine.Condition = condition;
                                        ProfileProcessor.CurrentActionLine.ConvertedSpecial = value;
                                    }
                                }
                                else if (ProfileProcessor.CurrentActionLine.Action.Contains("use_item"))
                                {
                                    ProfileProcessor.Locals.Add("use");
                                    ProfileProcessor.CurrentActionLine.Action = $"use.{nameValue}";
                                    ProfileProcessor.CurrentActionLine.Type = ActionType.UseItem;
                                }
                                break;
                        }
                    }
                }
            }
        }
    }
}
