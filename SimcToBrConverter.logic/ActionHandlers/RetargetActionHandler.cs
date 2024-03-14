using SimcToBrConverter.logic.Utilities;

namespace SimcToBrConverter.logic.ActionHandlers
{
    internal class RetargetActionHandler : BaseActionHandler
    {
        public override bool CanHandle()
        {
            return ProfileProcessor.CurrentActionLine.Action.Contains("retarget");
        }

        public override void Handle()
        {
            ProfileProcessor.CurrentActionLine.Action = ProfileProcessor.CurrentActionLine.Action.Replace("retarget_","");
            ProfileProcessor.CurrentActionLine.Type = ActionType.Retarget;
        }
    }
}
