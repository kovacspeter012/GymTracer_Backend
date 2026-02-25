using GymTracer.Context;
using GymTracer.models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using System.Text.Json;

namespace GymTracer.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private GymTracerDbContext DbContext;

        

        public UserController(GymTracerDbContext dbContext) {
            this.DbContext = dbContext;
        }

        [HttpGet("/{id}/profile")]
        [Authorize(Roles = nameof(User_Role.customer) + "," + nameof(User_Role.trainer) + "," + nameof(User_Role.staff) +  "," + nameof(User_Role.admin))]
        public IActionResult GetUserById(int id)
        {
            var loggedInUserId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            var user = DbContext.Set<User>().FirstOrDefault(u => u.Id == id);

            if (user == null)
            {
                return StatusCode(404,new { error = "User not found!" });
            }

            

            if (!(user.Id.ToString() == loggedInUserId || (user.Role == User_Role.staff || user.Role == User_Role.admin)))
            {
                return StatusCode(401, new { error = "Unauthorized" });
            }
            else
            {
                var cardOfUser = DbContext.Set<Card>().Where(c => c.UserId == user.Id);  
                List<long> cardsIds = [];
                foreach (var c in cardOfUser)
                {
                    cardsIds.Add(c.Id);
                }
                cardsIds.Add(1);

                return StatusCode(200, new {
                    user = new {
                        name = user.Name,
                        email = user.Email,
                        birthDate = user.BirthDate,
                        creationDate = user.CreationDate,
                        cards = cardsIds,
                    } 
                });
            }
        }

        [HttpPut("/{id}/profile")]
        [Authorize(Roles = nameof(User_Role.customer) + "," + nameof(User_Role.trainer) + "," + nameof(User_Role.staff) + "," + nameof(User_Role.admin))]
        public IActionResult ModifyUserData([FromBody] dynamic body, int id)
        {
            var loggedInUserId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            var user = DbContext.Set<User>().FirstOrDefault(u => u.Id == id);

            if (user == null)
            {
                return StatusCode(404, new { error = "User not found!" });
            }
            if (!(id.ToString() == loggedInUserId || (user.Role == User_Role.staff || user.Role == User_Role.admin)))
            {
                return StatusCode(401, new { error = "Unauthorized" });
            }

            User userToModifyWith = null!;
            try
            {
                var options = new JsonSerializerOptions()
                {
                    PropertyNameCaseInsensitive = true
                };
                userToModifyWith = JsonSerializer.Deserialize<User>(body, options) ?? new User();
            }
            catch
            {
                return StatusCode(400, new { error = "Incorrect Body Structure" });
            }

            var userToModify = DbContext.Set<User>().SingleOrDefault(g => g.Id == id);

            try
            {
                if (userToModify != null)
                {
                    userToModify.UpdateFrom(userToModifyWith);
                    DbContext.Update(userToModify);
                    DbContext.SaveChanges();
                    return GetUserById(id);
                }
                else
                {
                    return StatusCode(400, new { error = "Record not found" });
                }
            }
            catch
            {
                return StatusCode(500, new { error = "Incorrect Data" });
            }
        }

    }
}
