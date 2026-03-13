using System.Linq.Expressions;

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

        public ValidatorChain<TProp> Validate<TProp>(Expression<Func<T, TProp>> expression)
        {
            var compiledFunction = expression.Compile();
            var validationField = compiledFunction(validationModel);

            var validationFieldName = ((MemberExpression)expression.Body).Member.Name;

            return new ValidatorChain<TProp>(validationField, validationFieldName);
        }
    }
}
