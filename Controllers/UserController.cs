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
using System.Text.RegularExpressions;

namespace GymTracer.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public partial class UserController : ControllerBase
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

        [GeneratedRegex("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")]
        private static partial Regex EmailRegex();

        [HttpPut("{id}/profile")]
        [Authorize(Roles = nameof(User_Role.customer) + "," + nameof(User_Role.trainer) + "," + nameof(User_Role.staff) + "," + nameof(User_Role.admin))]
        public IActionResult ModifyUserData([FromBody] dynamic body, int id)
        {
            return this.Run(() =>
            {
                if (IsAuthorized(id))
                {
                    User userToModifyWith = models.User.Deserialize(body);

                    var userToModify = DbContext.Set<User>().SingleOrDefault(g => g.Id == id);

                    if (!EmailRegex().Match(userToModifyWith.Email).Success)
                        return BadRequest(new { error = "Az email címnek validnak kell lennie" });

                    var isUsedEmail = DbContext.Users.Any(u => u.Email == userToModifyWith.Email);
                    if (isUsedEmail)
                        return BadRequest(new { error = "Az email cím már használatban van" });

                    if (userToModify != null)
                    {
                        userToModify.UpdateFrom(userToModifyWith);
                        DbContext.Update(userToModify);
                        DbContext.SaveChanges();
                        return GetUserById(id);
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

        [HttpDelete("{id}")]
        [Authorize(Roles = nameof(User_Role.customer) + "," + nameof(User_Role.trainer) + "," + nameof(User_Role.staff) + "," + nameof(User_Role.admin))]
        public IActionResult DeactivateUser(int id)
        {
            return this.Run(() =>
            {
                if (IsAuthorized(id))
                {
                    var userToDeactivate = DbContext.Set<User>().SingleOrDefault(g => g.Id == id);

                    var cardsOfUser = DbContext.Set<Card>().Where(c => c.UserId == userToDeactivate!.Id).ToList();

                    var tokenOfUser = DbContext.Set<Token>().FirstOrDefault(t => t.UserId == id && t.RevokedAt > DateTime.Now);

                    if (userToDeactivate != null && userToDeactivate.Active != false)
                    {
                        userToDeactivate.Active = false;
                        DbContext.Update(userToDeactivate);
                        DbContext.SaveChanges();

                        if (cardsOfUser.Count != 0)
                        {
                            foreach (var c in cardsOfUser)
                            {
                                c.RevokedAt = DateTime.Now;
                                DbContext.Update(c);
                                DbContext.SaveChanges();
                            }
                        }
                        
                        tokenOfUser!.RevokedAt = DateTime.Now;
                        DbContext.Update(tokenOfUser);
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

        [NonAction]
        public bool IsAuthorized(int id)
        {
            var loggedInUserId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            var loggedInUser = DbContext.Set<User>().FirstOrDefault(u => u.Id.ToString() == loggedInUserId);

            var user = DbContext.Set<User>().FirstOrDefault(u => u.Id == id);

            if (user == null)
            {
                throw new ApiException(404, "User not found");
            }
            if (id.ToString() == loggedInUserId || (loggedInUser!.Role == User_Role.staff || loggedInUser.Role == User_Role.admin))
            {
                return true;
            }
            return false;
        }
    }
}
