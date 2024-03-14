using SimcToBrConverter.logic.Utilities;

namespace SimcToBrConverter.logic.LuaGenerators
{
    public interface ILuaGenerator
    {
        bool CanGenerate(ConversionResult conversionResult);
        string GenerateActionLineCode(ConversionResult conversionResult, string formattedCommand, string debugCommand, string convertedCondition, string listNameTag);
    }
}
