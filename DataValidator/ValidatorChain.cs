namespace GymTracer.DataValidator
{
    public readonly struct ValidatorChain<TProp>
    {
        private readonly TProp validationField;
        private readonly string validationFieldName;
        private readonly Dictionary<string, string> errors;
        public bool HasFailed { get; }

        public ValidatorChain(TProp validationField, string validationFieldName, Dictionary<string, string> errors, bool hasFailed = false)
        {
            this.validationField = validationField;
            this.validationFieldName = validationFieldName;
            this.errors = errors;
            this.HasFailed = hasFailed;
        }

        public ValidatorChain<TProp> AddError(string message)
        {
            errors.TryAdd(validationFieldName, message);
            return new ValidatorChain<TProp>(validationField, validationFieldName, errors, true);
        }

        public ValidatorChain<TProp> NotNull()
        {
            if(!HasFailed && this.validationField is null)
                return AddError($"A(z) {validationFieldName} mezőt meg kell adni");

            return this;
        }
    }
}
