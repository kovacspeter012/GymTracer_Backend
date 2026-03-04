using System.Security.Claims;
using GymTracer.Auth;
using GymTracer.Context;
using GymTracer.Exceptions;
using GymTracer.Extensions;
using GymTracer.models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GymTracer.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TicketController : ControllerBase
    {
        private readonly GymTracerDbContext DbContext;

        public TicketController(GymTracerDbContext dbContext)
        {
            this.DbContext = dbContext;
        }

        [HttpGet]
        public IActionResult GetAllTickets()
        {
            var tickets = DbContext.Set<Ticket>();

            return StatusCode(200, tickets.Select(t => new
            {
                t.Id,
                t.Type,
                t.Description,
                t.IsStudent,
                t.Price,
                t.MaxUsage
            }));
        }

        [HttpGet("user/{id}")]
        [Authorize(Roles = nameof(User_Role.customer) + "," + nameof(User_Role.trainer) + "," + nameof(User_Role.staff) + "," + nameof(User_Role.admin))]
        public IActionResult GetTIcketsOfAUser(int id)
        {
            return this.Run(() =>
            {
                if (IsAuthorized(id))
                {
                    var userTickets = DbContext.Set<UserTicket>().Where(u => u.UserId == id).Include(u => u.Ticket);

                    if (userTickets != null)
                    {
                        return StatusCode(200, userTickets.Select(ut => new
                        {
                            ut.Ticket.Type,
                            ut.Ticket.Description,
                            ut.Ticket.IsStudent,
                            ut.ExpirationDate,
                            usagesLeft = ut.UsageAmount
                        }));
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
