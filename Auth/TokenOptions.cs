namespace GymTracer.Auth
{
    public class TokenOptions
    {
        public const string SectionName = "TokenHandler";

        public int Length { get; set; } = 128;
    }
}
