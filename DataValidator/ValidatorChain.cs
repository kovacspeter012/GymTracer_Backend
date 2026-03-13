namespace GymTracer.DataValidator
{
    public readonly struct ValidatorChain<TProp>
    {
        public TProp ValidationField { get; }
        public string ValidationFieldName { get; }
        public string DisplayName { get; }
        public Dictionary<string, string> Errors { get; }
        public bool HasFailed { get; }

        public ValidatorChain(TProp validationField, string validationFieldName, Dictionary<string, string> errors, string? displayName = null, bool hasFailed = false)
        {
            this.ValidationField = validationField;
            this.ValidationFieldName = validationFieldName;
            this.DisplayName = displayName ?? validationFieldName;
            this.Errors = errors;
            this.HasFailed = hasFailed;
        }

        public ValidatorChain<TProp> AddError(string message)
        {
            Errors.TryAdd(ValidationFieldName, message);
            return new ValidatorChain<TProp>(ValidationField, ValidationFieldName, Errors, DisplayName, true);
        }

        public ValidatorChain<TProp> NotNull()
        {
            if(!HasFailed && this.ValidationField is null)
                return AddError($"A(z) {DisplayName} megadása kötelező");

            return this;
        }
    }
}
