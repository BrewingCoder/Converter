using System.Text;
using SimcToBrConverter.logic.Utilities;

namespace SimcToBrConverter.logic.LuaGenerators
{
    public class DefaultLuaGenerator : BaseLuaGenerator
    {
        public override bool CanGenerate(ConversionResult conversionResult)
        {
            return conversionResult.ActionLine.Type == ActionType.Default;
        }

        public override string GenerateActionLineCode(ConversionResult conversionResult, string formattedCommand, string debugCommand, string convertedCondition, string listNameTag)
        {
            convertedCondition = PrependConditions(convertedCondition);

            var output = new StringBuilder();

            output.AppendLine($"    if cast.able.{formattedCommand}(){convertedCondition} then");
            if (ProfileProcessor.PreviousActionLine.Comment.Contains("pool_resource,for_next=1"))
            {
                var poolCondition = ProfileProcessor.PreviousActionLine.Condition;
                if (!string.IsNullOrEmpty(poolCondition))
                {
                    output.AppendLine($"        if {ProfileProcessor.PreviousActionLine.Condition} then");
                    output.AppendLine($"            if cast.pool.{formattedCommand}() then return true end");
                    output.AppendLine($"        end");
                }
                else
                    output.AppendLine($"            if cast.pool.{formattedCommand}() then return true end");
            }
            output.AppendLine($"        if cast.{formattedCommand}() then ui.debug(\"Casting {debugCommand}{listNameTag}\") return true end");
            output.AppendLine($"    end");

            SpellRepository.AddSpell(formattedCommand, "abilities");

            return output.ToString();
        }
    }
}
