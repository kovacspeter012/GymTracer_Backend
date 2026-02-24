using GymTracer.Context;
using GymTracer.models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
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
            var user = DbContext.Set<User>().Include(u=> u.Cards).FirstOrDefault(u => u.Id == id);

            if (user == null)
            {
                return StatusCode(404,new { error = "User not found!" });
            }
            else
            {
                List<long> cardsIds = [];
                foreach (var c in user.Cards)
                {
                    cardsIds.Add(c.Id);
                }

                return StatusCode(200, new {user = new {
                    name = user.Name,
                    email = user.Email,
                    birthDate = user.BirthDate,
                    creationDate = user.CreationDate,
                    cards = user.Cards,
                } });
            }
        }
        
    }
}
