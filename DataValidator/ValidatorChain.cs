namespace GymTracer.DataValidator
{
    public readonly struct ValidatorChain<TProp>
    {
        public TProp ValidationField { get; }
        public string ValidationFieldName { get; }
        public Dictionary<string, string> Errors { get; }
        public bool HasFailed { get; }

        public ValidatorChain(TProp validationField, string validationFieldName, Dictionary<string, string> errors, bool hasFailed = false)
        {
            this.ValidationField = validationField;
            this.ValidationFieldName = validationFieldName;
            this.Errors = errors;
            this.HasFailed = hasFailed;
        }

        public ValidatorChain<TProp> AddError(string message)
        {
            Errors.TryAdd(ValidationFieldName, message);
            return new ValidatorChain<TProp>(ValidationField, ValidationFieldName, Errors, true);
        }

        public ValidatorChain<TProp> NotNull()
        {
            if(!HasFailed && this.ValidationField is null)
                return AddError($"A(z) {ValidationFieldName} mezőt meg kell adni");

            return this;
        }
    }
}
