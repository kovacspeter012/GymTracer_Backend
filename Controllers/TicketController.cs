using GymTracer.Auth;
using GymTracer.Context;
using GymTracer.models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

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
    }
}
