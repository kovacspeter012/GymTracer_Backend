using GymTracer.Context;
using GymTracer.Exceptions;
using GymTracer.Extensions;
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

        [HttpGet("{id}/profile")]
        [Authorize(Roles = nameof(User_Role.customer) + "," + nameof(User_Role.trainer) + "," + nameof(User_Role.staff) +  "," + nameof(User_Role.admin))]
        public IActionResult GetUserById(int id)
        {
            return this.Run(() =>
            {
                if (IsAuthorized(id))
                {
                    var user = DbContext.Set<User>().FirstOrDefault(u => u.Id == id);

                    var cardOfUser = DbContext.Set<Card>().Where(c => c.UserId == user!.Id);
                    List<long> cardsIds = [];
                    foreach (var c in cardOfUser)
                    {
                        cardsIds.Add(c.Id);
                    }
                    cardsIds.Add(1);

                    return StatusCode(200, new
                    {
                        user = new
                        {
                            name = user!.Name,
                            email = user.Email,
                            birthDate = user.BirthDate,
                            creationDate = user.CreationDate,
                            cards = cardsIds,
                        }
                    });
                }
                else
                {
                    throw new ApiException(401, "Unauthorized");
                }
            });
        }

        [HttpPut("{id}/profile")]
        [Authorize(Roles = nameof(User_Role.customer) + "," + nameof(User_Role.trainer) + "," + nameof(User_Role.staff) + "," + nameof(User_Role.admin))]
        public IActionResult ModifyUserData([FromBody] dynamic body, int id)
        {
            return this.Run(() =>
            {
                if (IsAuthorized(id))
                {
                    var options = new JsonSerializerOptions()
                    {
                        PropertyNameCaseInsensitive = true
                    };
                    var userToModifyWith = JsonSerializer.Deserialize<User>(body, options) ?? new User();

                    var userToModify = DbContext.Set<User>().SingleOrDefault(g => g.Id == id);

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
                else
                {
                    throw new ApiException(401, "Unauthorized");
                }
            });   
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = nameof(User_Role.customer) + "," + nameof(User_Role.trainer) + "," + nameof(User_Role.staff) + "," + nameof(User_Role.admin))]
        public IActionResult DeactivateUser(int id)
        {
            return this.Run(() =>
            {
                if (IsAuthorized(id))
                {
                    var userToDeactivate = DbContext.Set<User>().SingleOrDefault(g => g.Id == id);
                    if (userToDeactivate != null && userToDeactivate.Active != false)
                    {
                        userToDeactivate.Active = false;
                        DbContext.Update(userToDeactivate);
                        DbContext.SaveChanges();
                        return StatusCode(204);
                    }
                    else
                    {
                        throw new ApiException(404, "User not found");
                    }
                }
                else
                {
                    throw new ApiException(401, "Unauthorized");
                }

            });
            
        }

        public bool IsAuthorized(int id)
        {
            var loggedInUserId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            var user = DbContext.Set<User>().FirstOrDefault(u => u.Id == id);

            if (user == null)
            {
                throw new ApiException(404, "User not found");
            }
            if (!(id.ToString() == loggedInUserId || (user.Role == User_Role.staff || user.Role == User_Role.admin)))
            {
                return false;
            }
            return true;
        }
    }
}
