namespace SimcToBrConverter.logic.SpecialHandlers
{
    public interface ISpecialHandler
    {
        bool CanHandle();
        void Handle();
    }
}
