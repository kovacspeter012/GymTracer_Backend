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

        public bool ComparePasswords(string password, string passwordHash)
        {
            var passwordParts = passwordHash.Split("$");
            if (passwordParts.Length != 6)
                return false;

            if (passwordParts[1].ToLower() != "pbkdf2")
                return false;

            HashAlgorithmName hashAlgorithm = new HashAlgorithmName(passwordParts[2].ToLower());

            if (!int.TryParse(passwordParts[3], out int iterations))
                return false;

            if (string.IsNullOrEmpty(passwordParts[4]))
                return false;

            try
            {
                byte[] salt = Convert.FromBase64String(passwordParts[4]);
                byte[] hashBytes = Convert.FromBase64String(passwordParts[5]);
                int hashLength = hashBytes.Length;

                string freshPasswordHash = HashPassword(password, salt, iterations, hashAlgorithm, hashLength);
                return freshPasswordHash == passwordHash;

            }
            catch (Exception ex)
            {
                return false;
            }

        }

        public string HashPassword(string password)
        {
            return HashPassword(password, GenerateSalt());
        }

        public string HashPassword(string password, byte[] salt)
        {
            return HashPassword(password, salt, this.iterations, this.algorithm, this.hashLength);
        }
        private string HashPassword(string password, byte[] salt, int iterations, HashAlgorithmName algorithm, int hashLength)
        {
            byte[] passwordHash = Rfc2898DeriveBytes.Pbkdf2(password, salt, iterations, algorithm, hashLength);

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
