using Microsoft.Extensions.Options;
using System.Security.Cryptography;

namespace GymTracer.Auth
{
    public class PasswordHandler
    {
        private readonly HashAlgorithmName algorithm;
        private readonly int iterations;
        private readonly int hashLength;
        private readonly int saltLength;
        public PasswordHandler(IOptions<PasswordOptions> options)
        {
            var settings = options.Value;

            this.algorithm = new HashAlgorithmName(settings.AlgorithmName);
            this.iterations = settings.Iterations;
            this.hashLength = settings.HashLength;
            this.saltLength = settings.SaltLength;
        }

        public string HashPassword(string password, byte[] salt)
        {
            byte[] passwordHash = Rfc2898DeriveBytes.Pbkdf2(password, salt, this.iterations, this.algorithm, this.hashLength);

            string saltString = Convert.ToBase64String(salt);
            string hashString = Convert.ToBase64String(passwordHash);

            return $"$pbkdf2${algorithm.Name?.ToLower()}${iterations}${saltString}${hashString}";
        }

        public byte[] GenerateSalt()
        {
            return RandomNumberGenerator.GetBytes(saltLength);
        }


    }
}
