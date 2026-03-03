using GymTracer.Auth;
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
        private readonly TokenHandler tokenHandler;

        public UserController(GymTracerDbContext dbContext, TokenHandler tokenHandler) {
            this.DbContext = dbContext;
            this.tokenHandler = tokenHandler;
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

                    var cardsOfUser = DbContext.Set<Card>().Where(c => c.UserId == userToDeactivate!.Id && c.RevokedAt == null).ToList();

                    var tokensOfUser = DbContext.Set<Token>().Where(t => t.UserId == id && t.RevokedAt > tokenHandler.Now()).ToList();

                    if (userToDeactivate != null && userToDeactivate.Active != false)
                    {
                        using var transaction = DbContext.Database.BeginTransaction();
                        userToDeactivate.Active = false;
                        DbContext.Update(userToDeactivate);
                        DbContext.SaveChanges();

                        if (cardsOfUser.Count != 0)
                        {
                            foreach (var c in cardsOfUser)
                            {
                                c.RevokedAt = tokenHandler.Now();
                                DbContext.Update(c);
                                DbContext.SaveChanges();
                            }
                        }

                        if (tokensOfUser.Count != 0)
                        {
                            foreach (var t in tokensOfUser)
                            {
                                t.RevokedAt = tokenHandler.Now();
                                DbContext.Update(t);
                                DbContext.SaveChanges();
                            }
                        }
                        transaction.Commit();

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

        [HttpGet("{id}/card")]
        [Authorize(Roles = nameof(User_Role.customer) + "," + nameof(User_Role.trainer) + "," + nameof(User_Role.staff) + "," + nameof(User_Role.admin))]
        public IActionResult GetUsersCard(int id)
        {
            return this.Run(() =>
            {
                if (IsAuthorized(id))
                {
                    var user = DbContext.Set<User>().FirstOrDefault(u => u.Id == id);

                    var cardsOfUser = DbContext.Set<Card>().Where(c => c.UserId == user!.Id && c.RevokedAt == null).ToList();

                    if (cardsOfUser.Count != 0)
                    {
                        return StatusCode(200, cardsOfUser.Select(c => new
                        {
                            c.Id,
                            c.Code
                        }));
                    }
                    else
                    {
                        throw new ApiException(404, "No card found for this user");
                    }
                }
                else
                {
                    throw new ApiException(401, "Unauthorized");
                }

            });

        }

        [HttpPost("{id}/card")]
        [Authorize(Roles = nameof(User_Role.customer) + "," + nameof(User_Role.trainer) + "," + nameof(User_Role.staff) + "," + nameof(User_Role.admin))]
        public IActionResult PostNewCard(int id)
        {
            return this.Run(() =>
            {
                if (IsAuthorized(id))
                {
                    Card newCard = new Card();
                    newCard.UserId = id;
                    newCard.CreatedAt = tokenHandler.Now();
                    newCard.Code = Guid.NewGuid();


                    DbContext.Update(newCard);
                    DbContext.SaveChanges();

                    var card = DbContext.Set<Card>().Where(c => c.Code == newCard.Code);
                    return StatusCode(200, card.Select(c => new
                    {
                        c.Id,
                        c.Code
                    }));
                    
                }
                else
                {
                    throw new ApiException(401, "Unauthorized");
                }

            });

        }

        [HttpDelete("{id}/card/{card_id}")]
        [Authorize(Roles = nameof(User_Role.customer) + "," + nameof(User_Role.trainer) + "," + nameof(User_Role.staff) + "," + nameof(User_Role.admin))]
        public IActionResult DeleteCard(int id, int card_id)
        {
            return this.Run(() =>
            {
                if (IsAuthorized(id))
                {
                    var cardToDeactivate = DbContext.Set<Card>().FirstOrDefault(c => c.Id == card_id && c.RevokedAt == null);

                    if (cardToDeactivate != null)
                    {
                        cardToDeactivate.RevokedAt = tokenHandler.Now();

                        DbContext.Update(cardToDeactivate);
                        DbContext.SaveChanges();

                        return StatusCode(204);
                    }
                    else
                    {
                        throw new ApiException(404, "No card found");
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
