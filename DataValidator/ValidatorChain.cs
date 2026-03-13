namespace GymTracer.DataValidator
{
    public class ValidatorChain<TProp>
    {
        private readonly TProp validationField;
        private readonly string validationFieldName;

        public string Message { get; private set; } = string.Empty;
        public bool IsValid { get; private set; } = true;

        public ValidatorChain(TProp validationField, string validationFieldName)
        {
            this.validationField = validationField;
            this.validationFieldName = validationFieldName;
        }

        public ValidatorChain<TProp> NotNull()
        {
            if(this.validationField is null)
            {
                Message = $"A(z) {validationFieldName} mezőt meg kell adni";
                IsValid = false;
            }

            return this;
        }
    }
}
