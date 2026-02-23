using System.Security.Cryptography;

namespace GymTracer.Auth
{
    public static class TokenHandler
    {
        public static string GenerateToken(int length)
        {
            return RandomNumberGenerator.GetHexString(128);
        }
    }
}
