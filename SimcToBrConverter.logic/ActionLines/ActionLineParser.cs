using System.Text.RegularExpressions;
using SimcToBrConverter.logic.Utilities;

namespace SimcToBrConverter.logic.ActionLines
{
    public class ActionLineParser
    {
        //actions.serenity_aoe+=/tiger_palm,,target_if=min:debuff.mark_of_the_crane.remains,if=!debuff.skyreach_exhaustion.up*20&combo_strike&active_enemies=5
        private static readonly Regex ActionPattern = new(
            @"^actions\.?(?<listName>\w+)?(\+=/|=)(?<action>[^,]+)(?:(?!,if=|,value=|,op=),(?<specialHandling>[^,]+(?:,[^,]+)*?)(?=(?:,if=|,value=|,op=|$)))?(?:,value=(?<value>[^,]+))?(?:,op=(?<op>[^,]+))?(?:,if=(?<condition>.+))?$",
            RegexOptions.Compiled);
        private static readonly Regex CommentPattern = new(
            @"^actions\.?(?:\w+)?(?:(?=\+=/)|(?==))(?:\+=/|=)(?<comment>.+)$",
            RegexOptions.Compiled);

        public static IParseResult ParseActionLine(string line)
        {
            //TODO temp hack for bad profiles that contain a double comma
            line = line.Replace(",,", ",");

            var match = ActionPattern.Match(line);
            if (!match.Success)
                throw new InvalidOperationException($"Failed to process the line: {line}");

            var listName = match.Groups["listName"].Value.TrimStart('.');
            if (string.IsNullOrEmpty(listName)) listName = "combat";
            var action = match.Groups["action"].Value;
            var specialHandling = match.Groups["specialHandling"].Value;
            var condition = match.Groups["condition"].Value;
            var value = match.Groups["value"].Value;
            var op = match.Groups["op"].Value;
            var comment = CommentPattern.Match(line).Groups["comment"].Value;

            if (string.IsNullOrEmpty(action))
                throw new InvalidOperationException($"Failed to group the action from the line: {line}");
            List<string> conditions = new();
            return new ActionLine(listName, action, specialHandling, value, op, condition, comment, ActionType.Default, "", ActionType.Default);
        }
    }
}
