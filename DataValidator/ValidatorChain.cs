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

        public ValidatorChain<TProp> Equal(TProp other, string? customMessage = null)
        {
            if(!HasFailed)
            {
                bool areEqual = EqualityComparer<TProp>.Default.Equals(this.ValidationField, other);
                if (!areEqual)
                {
                    string message = customMessage ?? $"A(z) {this.DisplayName} meg kell egyezzen ezzel: {other}";
                    return AddError(message);
                }
            }
            return this;
        }

        public ValidatorChain<TProp> NotEqual(TProp other, string? customMessage = null)
        {
            if(!HasFailed)
            {
                bool areEqual = EqualityComparer<TProp>.Default.Equals(this.ValidationField, other);
                if (areEqual)
                {
                    string message = customMessage ?? $"A(z) {this.DisplayName} nem lehet egyenlő ezzel: {other}";
                    return AddError(message);
                }
            }
            return this;
        }

        public ValidatorChain<TProp> Must(Func<TProp, bool> predicate, string customMessage)
        {
            if(!HasFailed && this.ValidationField is not null && !predicate(this.ValidationField))
                return AddError(customMessage);
            return this;
        }
    }
}
