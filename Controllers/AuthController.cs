using GymTracer.Auth;
using GymTracer.Context;
using GymTracer.Models.Dtos;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Text.RegularExpressions;

namespace GymTracer.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public partial class AuthController : ControllerBase
    {
        private readonly GymTracerDbContext dbContext;
        private readonly PasswordHandler passwordHandler;

        public AuthController(GymTracerDbContext dbContext, PasswordHandler passwordHandler)
        {
            this.dbContext = dbContext;
            this.passwordHandler = passwordHandler;
        }

        [GeneratedRegex("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")]
        private static partial Regex EmailRegex();

        [HttpPost("registration")]
        public IActionResult Registration([FromBody] UserRegistrationDto? User)
        {

            if(User is null || string.IsNullOrEmpty(User.Name) || string.IsNullOrEmpty(User.Email) || string.IsNullOrEmpty(User.Password))
                return BadRequest(new { error = "Hibás adatok!" });

            if(User.Password.Length < 8)
                return BadRequest(new { error = "A jelszónak legalább 8 karakterből kell állnia" });

            if(!EmailRegex().Match(User.Email).Success)
                return BadRequest(new { error = "Az email címnek validnak kell lennie" });

            if(User.Name.Trim() == "")
                return BadRequest(new { error = "A névnek validnak kell lennie" });

            var isUsedEmail = dbContext.Users.Any(u => u.Email == User.Email);
            if(isUsedEmail)
                return BadRequest(new { error = "Az email címnek egyedinek kell lennie" });

            try
            {
                var registeredUser = dbContext.Users.Add(new models.User()
                {
                    Email = User.Email,
                    Name = User.Name,
                    Password = passwordHandler.HashPassword(User.Password),
                    CreationDate = DateTime.UtcNow,
                    Role = models.User_Role.customer,
                });

                dbContext.SaveChanges();
            }
            catch (Exception ex)
            {
#if DEBUG
                return BadRequest(new { ex.Message, ex.StackTrace });
#else
                return BadRequest(new { error = "Hibás adatok!" });
#endif

            }

            return Ok(new { message = "Sikeres regisztráció!"} );
        }
    }
}
