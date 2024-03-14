﻿using SimcToBrConverter.logic.Utilities;

namespace SimcToBrConverter.logic.ConditionConverters
{
    /// <summary>
    /// Handles conditions related to the Global Cooldown (GCD) of abilities.
    /// </summary>
    public class GCDConditionConverter : BaseConditionConverter
    {
        /// <summary>
        /// Determines if the given condition starts with listed string prefix(es).
        /// </summary>
        /// <param name="condition">The condition string to check.</param>
        /// <returns>True if the condition starts with listed string(s), and false otherwise.</returns>
        public override bool CanConvert(string condition)
        {
            return condition.StartsWith("gcd.")||condition.StartsWith("prev_gcd");
        }

        /// <summary>
        /// Converts the given task related to the GCD into the appropriate format.
        /// </summary>
        /// <param name="spell">The spell or ability in question.</param>
        /// <param name="task">The specific task or condition to check.</param>
        /// <param name="command">The action command associated with the condition.</param>
        /// <returns>A tuple containing the converted condition, whether to negate the result, and whether the conversion was successful.</returns>
        public override (string Result, bool Negate, bool Converted) ConvertTask(string conditionType, string spell, string task, string command, string op)
        {
            string result;
            bool negate = false;
            bool converted = true;
            if (string.IsNullOrEmpty(task))
            {
                task = spell;
                spell = command;
            }
            if (conditionType == "prev_gcd")
            {
                op = spell;
                spell = task;
                task = conditionType;
            }
            switch (task)
            {
                case "remains":
                    result = $"cd.{spell}.remains()";
                    break;
                case "max":
                    result = $"unit.gcd(true)";
                    break;
                case "prev_gcd":
                    spell = StringUtilities.ConvertToCamelCase(spell);
                    result = $"cast.last.{spell}({op})";
                    break;
                default:
                    result = ""; // Handle unknown tasks
                    converted = false;
                    break;
            }

            return (result, negate, converted);
        }
    }
}
