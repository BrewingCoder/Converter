namespace SimcToBrConverter.logic.SpecialHandlers
{
    public abstract class BaseSpecialHandler : ISpecialHandler
    {
        public abstract bool CanHandle();

        public abstract void Handle();

        public List<string> SplitSpecialHandling()
        {
            List<string> specialHandling = new();
            if (ProfileProcessor.CurrentActionLine.SpecialHandling.Contains(','))
                specialHandling = ProfileProcessor.CurrentActionLine.SpecialHandling.Split(',').ToList();
            else
                specialHandling.Add(ProfileProcessor.CurrentActionLine.SpecialHandling);

            return specialHandling;
        }
    }
}
