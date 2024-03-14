using SimcToBrConverter.logic.Utilities;

namespace SimcToBrConverter.logic.ActionHandlers
{
    public class VariableActionHandler : BaseActionHandler
    {
        public override bool CanHandle()
        {
            return ProfileProcessor.CurrentActionLine.ListName.Contains("variables") || ProfileProcessor.CurrentActionLine.Action.Contains("variable");
        }

        public override void Handle()
        {
            ProfileProcessor.CurrentActionLine.Type = ActionType.Variable;
            var nameValue = ProfileProcessor.CurrentActionLine.SpecialHandling.Replace("name=", "").Trim();
            // Check if the first character is a digit
            if (char.IsDigit(nameValue[0]))
            {
                nameValue = $"value{nameValue}";
            }
            var opValue = ProfileProcessor.CurrentActionLine.Condition.Replace("op=", "").Trim();

            ProfileProcessor.CurrentActionLine.Action = $"var.{nameValue}";
            ProfileProcessor.CurrentActionLine.Condition = opValue;
        }
    }
}
