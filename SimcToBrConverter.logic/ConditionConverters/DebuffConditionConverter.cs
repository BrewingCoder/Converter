﻿using SimcToBrConverter.logic.Utilities;

namespace SimcToBrConverter.logic.ConditionConverters
{
    /// <summary>
    /// Handles the conversion of conditions that start with "dot." or "debuff." prefixes.
    /// </summary>
    public class DebuffConditionConverter : BaseConditionConverter
    {
        /// <summary>
        /// Determines if the given condition starts with listed string prefix(es).
        /// </summary>
        /// <param name="condition">The condition string to check.</param>
        /// <returns>True if the condition starts with listed string(s), and false otherwise.</returns>
        public override bool CanConvert(string condition)
        {
            return condition.StartsWith("dot.") ||
                   condition.StartsWith("debuff.") ||
                   condition.StartsWith("persistent_multiplier") ||
                   condition.StartsWith("refreshable") ||
                   condition.StartsWith("druid.rake") ||
                   condition.StartsWith("active_dot");
        }

        /// <summary>
        /// Converts the given task related to a spell into its corresponding representation.
        /// </summary>
        /// <param name="spell">The spell associated with the task.</param>
        /// <param name="task">The task to convert.</param>
        /// <param name="command">The action command.</param>
        /// <returns>A tuple containing the converted task, a flag indicating if negation is needed, and a flag indicating if the conversion was successful.</returns>
        public override (string Result, bool Negate, bool Converted) ConvertTask(string conditionType, string spell, string task, string command, string op)
        {
            string result;
            bool negate = false;
            bool converted = true;
            if (conditionType == "refreshable" || conditionType == "persistent_multiplier")
            {
                task = conditionType;
                spell = command;
            }
            if (conditionType == "active_dot")
            {
                task = "value";
            }

            switch (task)
            {
                case "up":
                case "react":
                case "ticking":
                    result = $"debuff.{spell}.exists(PLACEHOLDER)";
                    break;
                case "down":
                    result = $"debuff.{spell}.exists(PLACEHOLDER)";
                    negate = true; // Reverse the negation for "down"
                    break;
                case "remains":
                    result = $"debuff.{spell}.remains(PLACEHOLDER)";
                    break;
                case "stack":
                case "value":
                    result = $"debuff.{spell}.count(PLACEHOLDER)";
                    break;
                case "refreshable":
                    result = $"debuff.{spell}.refresh(PLACEHOLDER)";
                    break;
                case "pmultiplier":
                    result = $"debuff.{spell}.pmultiplier(PLACEHOLDER)";
                    break;
                case "persistent_multiplier":
                    result = $"debuff.{spell}.applied(PLACEHOLDER)";
                    break;
                case "ticks_gained_on_refresh":
                    result = $"debuff.{spell}.ticksGainedOnRefresh(PLACEHOLDER)";
                    break;
                default:
                    result = ""; // Unknown task
                    converted = false;
                    break;
            }

            if (!string.IsNullOrEmpty(result))
                SpellRepository.AddSpell(spell, "debuffs");

            return (result, negate, converted);
        }
    }
}
