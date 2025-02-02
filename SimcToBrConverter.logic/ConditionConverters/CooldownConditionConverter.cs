﻿namespace SimcToBrConverter.logic.ConditionConverters
{
    /// <summary>
    /// Handles the conversion of conditions related to cooldowns.
    /// </summary>
    public class CooldownConditionConverter : BaseConditionConverter
    {
        /// <summary>
        /// Determines if the given condition starts with listed string prefix(es).
        /// </summary>
        /// <param name="condition">The condition string to check.</param>
        /// <returns>True if the condition starts with listed string(s), and false otherwise.</returns>
        public override bool CanConvert(string condition)
        {
            return condition.StartsWith("cooldown.")||condition.StartsWith("linecd.")||condition.StartsWith("full_recharge_time");
        }

        /// <summary>
        /// Converts specific tasks related to cooldowns.
        /// </summary>
        /// <param name="spell">The spell associated with the cooldown.</param>
        /// <param name="task">The specific cooldown task to convert.</param>
        /// <param name="command">The action command associated with the condition.</param>
        /// <returns>A tuple containing the converted condition, a flag indicating if the condition should be negated, and a flag indicating if the conversion was successful.</returns>
        public override (string Result, bool Negate, bool Converted) ConvertTask(string conditionType, string spell, string task, string command, string op)
        {
            string result;
            bool negate = false;
            bool converted = true;

            if (conditionType == "linecd")
            {
                op = task;
                task = conditionType;
            }
            if (conditionType == "full_recharge_time")
            {
                task = conditionType;
                spell = command;
            }
            switch (task)
            {
                case "charges":
                    // Converts to a check for the number of charges available for the spell.
                    result = $"charges.{spell}.count()";
                    break;
                case "full_recharge_time":
                    // Converts to a check for the time until the spell is fully recharged.
                    result = $"charges.{spell}.timeTillFull()";
                    break;
                case "remains":
                    // Converts to a check for the remaining cooldown time for the spell.
                    if (spell == "slot")
                    {
                        if (!string.IsNullOrEmpty(op))
                        {
                            // Add 12 to the slot number to convert from SimC Trinket Slot ID to WoW Trinket Slot ID
                            op = (int.Parse(op) + 12).ToString();
                        }
                        result = $"cd.slot.remains({op})";
                    }
                    else
                        result = $"cd.{spell}.remains()";
                    break;
                case "linecd":
                    // Converts to a check to delay execution by specified time.
                    result = $"ui.delay(\"{spell}\",{op})";
                    break;
                case "ready":
                case "up":
                    // Converts to a check for the spell being ready to cast.
                    result = $"cd.{spell}.exists()";
                    negate = true; // Reverse the negation for "up"
                    break;
                case "duration":
                    // Converts to a check for the duration of the spell.
                    result = $"cd.{spell}.duration()";
                    break;
                default:
                    // Handle unknown tasks
                    result = "";
                    converted = false;
                    break;
            }

            return (result, negate, converted);
        }
    }
}
