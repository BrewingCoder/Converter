using SimcToBrConverter.logic.Utilities;

namespace SimcToBrConverter.logic.ActionHandlers
{
    internal class WaitActionHandler : BaseActionHandler
    {
        public override bool CanHandle()
        {
            return ProfileProcessor.CurrentActionLine.Action.Contains("wait");
        }

        public override void Handle()
        {
            ProfileProcessor.CurrentActionLine.Type = ActionType.Wait;
            ProfileProcessor.CurrentActionLine.Condition = $"{ProfileProcessor.CurrentActionLine.SpecialHandling.Replace("sec=", "").Trim()}+=&{ProfileProcessor.CurrentActionLine.Condition}";
        }
    }
}
