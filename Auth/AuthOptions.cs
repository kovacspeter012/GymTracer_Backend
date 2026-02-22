using Microsoft.AspNetCore.Authentication;

namespace GymTracer.Auth
{
    public class AuthOptions : AuthenticationSchemeOptions
    {
        public double ExpirationInMinutes { get; set; } = 5;
    }
}
