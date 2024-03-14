namespace SimcToBrConverter.logic.ActionHandlers
{
    public interface IActionHandler
    {
        bool CanHandle();
        void Handle();
    }
}
