using Microsoft.Extensions.Options;
using System.Security.Cryptography;
using System.Text;

namespace GymTracer.Auth
{
    public class TokenHandler
    {
        private readonly AuthOptions authSettings;
        public TokenHandler(IOptions<AuthOptions> authOptions)
        {
            this.authSettings = authOptions.Value;
        }
        public void GenerateTokenData(out string tokenString, out string tokenHash, out DateTime createdAt, out DateTime revokedAt)
        {
            tokenString = GenerateTokenString();
            tokenHash = HashToken(tokenString);
            createdAt = DateTime.UtcNow;
            revokedAt = DateTime.UtcNow.AddMinutes(authSettings.ExpirationInMinutes);
        }

        public DateTime Now()
        {
            return DateTime.UtcNow;
        }
        public string HashToken(string tokenString)
        {
            byte[] hashedData = SHA256.HashData(Encoding.UTF8.GetBytes(tokenString));
            return Convert.ToBase64String(hashedData);
        }

        private string GenerateTokenString()
        {
            return RandomNumberGenerator.GetHexString(authSettings.TokenLength);
        }
    }
}
