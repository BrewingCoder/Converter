using SimcToBrConverter.logic.Utilities;

namespace SimcToBrConverter.logic.ActionHandlers
{
    public class ActionListActionHandler : BaseActionHandler
    {
        public ActionListActionHandler() : base() { }

        public override bool CanHandle()
        {
            return ProfileProcessor.CurrentActionLine.Action.Contains("run_action_list") || ProfileProcessor.CurrentActionLine.Action.Contains("call_action_list");
        }

        public override void Handle()
        {
            if (ProfileProcessor.CurrentActionLine.Action.Contains("run_action_list") || ProfileProcessor.CurrentActionLine.Action.Contains("call_action_list"))
            {
                ProfileProcessor.CurrentActionLine.Type = ActionType.ActionList;
                // Extract the name of the action list from the SpecialHandling property
                var actionListName = ProfileProcessor.CurrentActionLine.SpecialHandling.Replace("name=", "").Trim();
                ProfileProcessor.CurrentActionLine.Action = $"actionList.{actionListName}";
            }
        }

    }
}