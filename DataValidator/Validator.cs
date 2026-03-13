using System.Runtime.CompilerServices;

namespace GymTracer.DataValidator
{
    public static class Validator
    {
        public static Validator<T> Create<T>(T validatonTarget)
        {
            return new Validator<T>(validatonTarget);
        }
    }

    public class Validator<T>
    {
        private readonly T validationModel;
        public Dictionary<string, string> Errors { get; } = [];
        public bool IsValid => Errors.Count == 0;
        public Validator(T validatonTarget)
        {
            this.validationModel = validatonTarget;
        }

        public ValidatorChain<TProp> Validate<TProp>(
            Func<T, TProp> callback,
            string? displayName = null,
            [CallerArgumentExpression(nameof(callback))] string expression = "")
        {
            int lastDot = expression.IndexOf('.');
            string fieldName = lastDot == -1 ? expression : expression[(lastDot + 1)..];

            TProp fieldValue = callback(validationModel);
            return new ValidatorChain<TProp>(fieldValue, fieldName, Errors, displayName);
        }
    }
}
