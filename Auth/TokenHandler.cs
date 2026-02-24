using Microsoft.Extensions.Options;
using System.Security.Cryptography;

namespace GymTracer.Auth
{
    public class TokenHandler
    {
        private readonly int length;
        public TokenHandler(IOptions<TokenOptions> options)
        {
            var settings = options.Value;

            this.length = settings.Length;
        }
        public string GenerateToken()
        {
            return RandomNumberGenerator.GetHexString(length);
        }
    }
}
