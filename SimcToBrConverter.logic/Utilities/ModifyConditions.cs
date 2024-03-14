﻿using SimcToBrConverter.logic.ActionLines;

namespace SimcToBrConverter.logic.Utilities
{
    internal class ModifyConditions
    {
        public static void Add(ActionLine actionLine, string condition)
        {
            if (!string.IsNullOrEmpty(actionLine.Condition))
                actionLine.Condition = StringUtilities.CheckForOr(condition) + "&" + StringUtilities.CheckForOr(actionLine.Condition);
            else
                actionLine.Condition = StringUtilities.CheckForOr(condition);
        }
    }
}
