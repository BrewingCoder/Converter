using SimcToBrConverter.logic.Utilities;

namespace SimcToBrConverter.logic.ActionHandlers
{
    public class PoolActionHandler : BaseActionHandler
    {
        public PoolActionHandler() : base() { }

        public override bool CanHandle()
        {
            return ProfileProcessor.CurrentActionLine.Action.Contains("pool_resource");
        }

        public override void Handle()
        {
            ProfileProcessor.CurrentActionLine.Type = ActionType.Pool;
        }

    }
}