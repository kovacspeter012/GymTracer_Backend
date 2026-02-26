using GymTracer.Context;
using GymTracer.Extensions;
using GymTracer.models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace GymTracer.Controllers
{
    [Authorize(Roles = nameof(User_Role.trainer) + "," + nameof(User_Role.staff) + "," + nameof(User_Role.admin))]
    [Route("api/[controller]")]
    [ApiController]
    public class TrainingController : ControllerBase
    {
        private readonly GymTracerDbContext dbContext;
        public TrainingController(GymTracerDbContext dbContext)
        {
            this.dbContext = dbContext;
        }

        [HttpPost("user/{id}")]
        public IActionResult CreateTraining(long id, [FromBody] dynamic body)
        {
            return this.Run(() =>
            {
                Training training = Training.Deserialize(body);

                string? userId = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
                if(userId is null)
                    return BadRequest("Hibás token!");

                if(dbContext.Trainings.Any(t => t.StartTime == training.StartTime || t.EndTime == training.EndTime))
                    return BadRequest("Ebben az időintervallumban már van regisztrált edzés!");

                if(training.Name.Trim() == "")
                    return BadRequest("Az edzésnek valid névvel kell rendelkeznie!");

                if(training.Description.Trim() == "")
                    return BadRequest("Az edzésnek valid leírással kell rendelkeznie!");

                // TODO: Feltöltött kép validáció
                if(training.Image.Trim() == "")
                    return BadRequest("Az edzésnek valid képpel kell rendelkeznie!");

                if(training.MaxParticipant == 0)
                    return BadRequest("Az edzésnek legalább 1 résztvevővel kell rendelkeznie!");

                Training dbTraining = new Training()
                {
                    Name = training.Name,
                    Description = training.Description,
                    Image = training.Image,
                    StartTime = training.StartTime,
                    EndTime = training.EndTime,
                    MaxParticipant = training.MaxParticipant,
                    TrainerId = long.Parse(userId), // TODO: Staff vagy admin létrehozhat más nevében
                    Active = true,
                };

                return Ok(training);
            });
        }
    }
}
