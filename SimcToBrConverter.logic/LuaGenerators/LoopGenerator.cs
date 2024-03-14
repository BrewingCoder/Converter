﻿using System.Text;
using SimcToBrConverter.logic.Utilities;

namespace SimcToBrConverter.logic.LuaGenerators
{
    public class LoopLuaGenerator : BaseLuaGenerator
    {
        public override bool CanGenerate(ConversionResult conversionResult)
        {
            return conversionResult.ActionLine.Type == ActionType.Loop;
        }

        public override string GenerateActionLineCode(ConversionResult conversionResult, string formattedCommand, string debugCommand, string convertedCondition, string listNameTag)
        {
            convertedCondition = PrependConditions(convertedCondition);
            convertedCondition = convertedCondition.Replace("PLACEHOLDER", "thisUnit");

            var output = new StringBuilder();

            output.AppendLine($"    for i = 1, #enemies.PLACEHOLDER_RANGE do");
            output.AppendLine($"        local thisUnit = enemies.PLACEHOLDER_RANGE[i]");
            output.AppendLine($"        if cast.able.{formattedCommand}(thisUnit){convertedCondition} then");
            output.AppendLine($"            if cast.{formattedCommand}(thisUnit) then ui.debug(\"Casting {debugCommand}{listNameTag}\") return true end");
            output.AppendLine($"        end");
            output.AppendLine($"    end");

            SpellRepository.AddSpell(formattedCommand, "abilities");

            return output.ToString();
        }
    }
}
