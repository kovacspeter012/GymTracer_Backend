using Microsoft.AspNetCore.Authentication;

namespace GymTracer.Auth
{
    public class AuthOptions : AuthenticationSchemeOptions
    {
        public const string SectionName = "AuthHandler";
        public double ExpirationInMinutes { get; set; } = 30;
        public int TokenLength { get; set; } = 128;
    }
}
