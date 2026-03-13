using System.Linq.Expressions;

namespace GymTracer.DataValidator
{
    public class Validator<T>
    {
        private readonly T validationModel;
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
