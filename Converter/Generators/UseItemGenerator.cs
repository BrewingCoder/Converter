﻿using SimcToBrConverter.ActionLines;
using SimcToBrConverter.Conditions;
using System.Text;

namespace SimcToBrConverter.Generators
{
    public class UseItemGenerator : BaseActionGenerator
    {
        public override bool CanGenerate(ActionType actionType)
        {
            return actionType == ActionType.UseItem;
        }

        public override string GenerateActionLineCode(ActionLine actionLine, string formattedCommand, string debugCommand, string convertedCondition, string listNameTag)
        {
            var output = new StringBuilder();

            output.AppendLine($"    if use.able.{formattedCommand}(){convertedCondition} then");
            output.AppendLine($"        if use.{formattedCommand}() then ui.debug(\"Using {debugCommand}{listNameTag}\") return true end");
            output.AppendLine($"    end");

            return output.ToString();
        }
    }
}
