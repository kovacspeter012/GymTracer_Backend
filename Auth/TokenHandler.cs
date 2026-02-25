using Microsoft.Extensions.Options;
using System.Security.Cryptography;

namespace GymTracer.Auth
{
    public class TokenHandler
    {
        private readonly AuthOptions authSettings;
        public TokenHandler(IOptions<AuthOptions> authOptions)
        {
            this.authSettings = authOptions.Value;
        }
        public string GenerateToken()
        {
            return RandomNumberGenerator.GetHexString(authSettings.TokenLength);
        }
    }
}
