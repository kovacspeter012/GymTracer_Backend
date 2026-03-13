using GymTracer.DataValidator;
using System.Text.RegularExpressions;

namespace GymTracer.Extensions
{
    public static partial class ValidatorExtension
    {
        #region STRING
        public static ValidatorChain<string> NotEmpty(this ValidatorChain<string> chain)
        {
            if (!chain.HasFailed && string.IsNullOrWhiteSpace(chain.ValidationField))
                return chain.AddError($"A(z) {chain.DisplayName} nem lehet üres");
            return chain;
        }

        public static ValidatorChain<string> MinLength(this ValidatorChain<string> chain, int length)
        {
            if (!chain.HasFailed && chain.ValidationField is not null && chain.ValidationField.Length < length)
                return chain.AddError($"A(z) {chain.DisplayName} legalább {length} hosszú kell legyen.");
            return chain;
        }
        public static ValidatorChain<string> MaxLength(this ValidatorChain<string> chain, int length)
        {
            if (!chain.HasFailed && chain.ValidationField is not null && chain.ValidationField.Length > length)
                return chain.AddError($"A(z) {chain.DisplayName} legfeljebb {length} hosszú kell legyen.");
            return chain;
        }

        [GeneratedRegex("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")]
        private static partial Regex EmailRegex();
        public static ValidatorChain<string> Email(this ValidatorChain<string> chain)
        {
            if (!chain.HasFailed && chain.ValidationField is not null && !EmailRegex().IsMatch(chain.ValidationField))
                return chain.AddError($"A(z) {chain.DisplayName} nem valid E-mail címként.");
            return chain;
        }
        public static ValidatorChain<string> Matches(this ValidatorChain<string> chain, Regex regex, string? customMessage = null)
        {
            if (!chain.HasFailed && chain.ValidationField is not null && !regex.IsMatch(chain.ValidationField))
            {
                string message = customMessage ?? $"A(z) {chain.DisplayName} nem felelt meg a validációs feltételnek";
                return chain.AddError(message);
            }
            return chain;
        }
        public static ValidatorChain<string> Matches(this ValidatorChain<string> chain, string regexString, string? customMessage = null)
        {
            if (!chain.HasFailed && chain.ValidationField is not null && !Regex.IsMatch(chain.ValidationField, regexString))
            {
                string message = customMessage ?? $"A(z) {chain.DisplayName} nem felelt meg a validációs feltételnek";
                return chain.AddError(message);
            }
            return chain;
        }

        #endregion

    }
}
