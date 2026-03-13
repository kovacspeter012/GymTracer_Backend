namespace GymTracer.DataValidator
{
    public class ValidatorChain<TProp>
    {
        private readonly TProp validationField;
        private readonly string validationFieldName;
        private readonly Dictionary<string, string> errors;
        public bool HasFailed { get; private set; } = false;

        public ValidatorChain(TProp validationField, string validationFieldName, Dictionary<string, string> errors)
        {
            this.validationField = validationField;
            this.validationFieldName = validationFieldName;
            this.errors = errors;
        }

        public void AddError(string message)
        {
            HasFailed = true;
            errors.TryAdd(validationFieldName, message);
        }

        public ValidatorChain<TProp> NotNull()
        {
            if(!HasFailed && this.validationField is null)
                AddError($"A(z) {validationFieldName} mezőt meg kell adni");

            return this;
        }
    }
}
