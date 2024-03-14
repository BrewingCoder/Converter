﻿namespace SimcToBrConverter.logic.ActionHandlers
{
    public abstract class BaseActionHandler : IActionHandler
    {
        public abstract bool CanHandle();
        //{
        //throw new NotImplementedException();
        //}

        public abstract void Handle();
        //{
        //    throw new NotImplementedException();
        //}
    }
}
