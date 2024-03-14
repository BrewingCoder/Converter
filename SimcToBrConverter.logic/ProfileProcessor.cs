using SimcToBrConverter.logic.ActionHandlers;
using SimcToBrConverter.logic.ActionLines;
using SimcToBrConverter.logic.ConditionConverters;
using SimcToBrConverter.logic.LuaGenerators;
using SimcToBrConverter.logic.SpecialHandlers;
using SimcToBrConverter.logic.Utilities;

namespace SimcToBrConverter.logic
{
    public class ProfileProcessor(IProcessorOptions options)
    {
        public static readonly List<IActionHandler> ActionHandlers = GetActionHandlers();
        public static readonly List<ISpecialHandler> SpecialHandlers = GetSpecialHandlers();
        public static readonly List<IConditionConverter> ConditionConverters = GetConditionConverters();
        public static readonly List<ILuaGenerator> LuaGenerators = GetLuaGenerators();
        public static readonly ConditionConversionService ConditionConversionService = new(ConditionConverters);
        public static ActionLine CurrentActionLine = new();
        public static ActionLine PreviousActionLine = new();
        public static List<string> NotConverted = [];
        public static List<ConversionResult> ConversionResults = [];
        public static List<string> ExtraVars = [];
        public static HashSet<string> Locals { get; set; } = [];


        public void ProcessProfile()
        {
            var profileLines = File.ReadAllLines(options.InputFile);
            var profileActionLines = ParseActions(profileLines);
            ProcessActionLines(profileActionLines);
            var luaCode = LuaCodeGenerator.GenerateLuaCode();
            File.WriteAllText(options.OutputFile, luaCode); 
            SpellRepository.PrintSpellsByType();
            
        }

        public static List<ISpecialHandler> GetSpecialHandlers()
        {
            return
            [
                new LineCdSpecialHandler(),
                new MaxEnergySpecialHandler(),
                new NameSpecialHandler(),
                new TargetIfSpecialHandler()
            ];
        }
        private static List<IActionHandler> GetActionHandlers()
        {
            return
            [
                new ActionListActionHandler(),
                new PoolActionHandler(),
                new RetargetActionHandler(),
                new UseItemActionHandler(),
                new VariableActionHandler(),
                new WaitActionHandler(),
                // DefaultActionHandler should always be the last in the list to ensure it acts as a fallback.
                new DefaultActionHandler()
            ];
        }
        public static List<IConditionConverter> GetConditionConverters()
        {
            return
            [
                new ActionConditionConverter(),
                new BuffConditionConverter(),
                new CooldownConditionConverter(),
                new DebuffConditionConverter(),
                new DruidConditionConverter(),
                new GCDConditionConverter(),
                new ItemConditionConverter(),
                new PowerConditionConverter(),
                new SpellTargetsConditionConverter(),
                new TalentConditionConverter(),
                new UnitConditionConverter(),
                new VariableConditionConverter()
            ];
        }
        public static List<ILuaGenerator> GetLuaGenerators()
        {
            return
            [
                new ActionListLuaGenerator(),
                new LoopLuaGenerator(),
                new MaxMinLuaGenerator(),
                new ModuleLuaGenerator(),
                new PoolLuaGenerator(),
                new RetargetLuaGenerator(),
                new UseItemLuaGenerator(),
                new VariableLuaGenerator(),
                new WaitLuaGenerator(),
                new DefaultLuaGenerator()
            ];
        }

        private static List<ActionLine> ParseActions(string[] profileLines)
        {
            List<ActionLine> actionLines = new();
            //string poolCondition = string.Empty;

            foreach (var line in profileLines)
            {
                if (line.StartsWith("actions"))
                {
                    var result = ActionLineParser.ParseActionLine(line);
                    if (result is ActionLine singleResult)
                    {
                        actionLines.Add(singleResult);
                    }
                    else if (result is MultipleActionLineResult multipleResult)
                    {
                        actionLines.AddRange(multipleResult.ActionLines);
                    }
                }
            }

            return actionLines;
        }
        private static void ProcessActionLines(List<ActionLine> actionLines)
        {
            foreach (var actionLine in actionLines)
            {
                CurrentActionLine = actionLine;
                NotConverted = new();
                // Process Actions
                foreach (var actionHandler in ActionHandlers)
                {
                    if (actionHandler.CanHandle())
                    {
                        actionHandler.Handle();
                        break; // Only one action handler should handle an action line
                    }
                }
                // Process Special Handling
                foreach (var specialHandler in SpecialHandlers)
                {
                    if (specialHandler.CanHandle())
                    {
                        specialHandler.Handle(); // There could be multiple special handlers for a single action line
                    }
                }
                if (CurrentActionLine.Type == ActionType.Ignore) continue;
                // Process Conditions
                if (string.IsNullOrEmpty(CurrentActionLine.Condition) && !string.IsNullOrEmpty(CurrentActionLine.Value))
                {
                    // If there is no condition, but there is a value, then treat the value as the condition for conversion purposes and restore the value
                    CurrentActionLine.Condition = CurrentActionLine.Value;
                    ConditionConversionService.ConvertCondition();
                    CurrentActionLine.Value = CurrentActionLine.Condition;
                    CurrentActionLine.Condition = string.Empty;
                }
                else
                    ConditionConversionService.ConvertCondition();
                // Add to Results
                ConversionResult conversionResult = new(CurrentActionLine, NotConverted, "");
                ConversionResults.Add(conversionResult);
            }
        }
      
    }
}
