using GymTracer.Auth;
using GymTracer.Context;
using GymTracer.Extensions;
using GymTracer.models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace GymTracer.Controllers
{
    [Authorize(Roles = nameof(User_Role.trainer) + "," + nameof(User_Role.staff) + "," + nameof(User_Role.admin))]
    [Route("api/[controller]")]
    [ApiController]
    public class TrainingController : ControllerBase
    {
        private readonly GymTracerDbContext dbContext;
        private readonly TokenHandler tokenHandler;

        public TrainingController(GymTracerDbContext dbContext, TokenHandler tokenHandler)
        {
            this.dbContext = dbContext;
            this.tokenHandler = tokenHandler;
        }

        [HttpGet("user/{id}")]
        public IActionResult GetTrainingsByTrainer(long id)
        {
            return this.Run(() =>
            {
                string? userId = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
                string? userRole = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Role)?.Value;
                if(userId is null || userRole is null)
                    return BadRequest("Hibás token!");

                if(userId != id.ToString())
                {
                    if(userRole != nameof(User_Role.admin) && userRole != nameof(User_Role.staff))
                        return BadRequest("Csak saját nevedben kérheted le az edzéseket!");
                    User? selectedUser = dbContext.Users.FirstOrDefault(u => u.Id == id);
                    if(selectedUser is null)
                        return BadRequest("Nincs ilyen felhasználó!");
                }
                List<Training> trainings = dbContext.Trainings.Include(t => t.Trainer).Where(t => t.TrainerId == id).OrderByDescending(t=> t.EndTime).ToList();
                return Ok(trainings.Select(t => new
                {
                    t.Id,
                    t.Name,
                    t.Description,
                    t.Image,
                    t.StartTime,
                    t.EndTime,
                    t.MaxParticipant,
                    t.TrainerId,
                    trainer = new
                    {
                        t.Trainer.Id,
                        t.Trainer.Name
                    }
                }));
            });
        }

        [HttpPost("user/{id}")]
        public IActionResult CreateTraining(long id, [FromBody] dynamic body)
        {
            return this.Run(() =>
            {
                Training training = Training.Deserialize(body);

                string? userId = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
                string? userRole = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Role)?.Value;
                if(userId is null || userRole is null)
                    return BadRequest("Hibás token!");

                if(userId != id.ToString())
                {
                    if(userRole != nameof(User_Role.admin) && userRole != nameof(User_Role.staff))
                        return BadRequest("Csak saját nevében hozhat létre edzést!");

                    User? selectedUser = dbContext.Users.FirstOrDefault(u => u.Id == id);
                    if(selectedUser is null)
                        return BadRequest("Nincs ilyen felhasználó!");
                }

                TimeSpan trainingTimeSpan = training.EndTime - training.StartTime;
                if(training.StartTime < tokenHandler.Now() || training.EndTime < tokenHandler.Now())
                    return BadRequest("Az edzés időpontja érvénytelen!");

                if(trainingTimeSpan.TotalMinutes < 5)
                    return BadRequest("Az edzés időtartama legalább 5 perc kell legyen!");
                else if(trainingTimeSpan.TotalHours > 2)
                    return BadRequest("Az edzés időtartama legfeljebb 2 óra lehet!");

                if(string.IsNullOrEmpty(training.Name) || training.Name.Trim() == "")
                    return BadRequest("Az edzésnek valid névvel kell rendelkeznie!");

                if(string.IsNullOrEmpty(training.Description) || training.Description.Trim() == "")
                    return BadRequest("Az edzésnek valid leírással kell rendelkeznie!");

                // TODO: Feltöltött kép validáció
                if(string.IsNullOrEmpty(training.Image) || training.Image.Trim() == "")
                    return BadRequest("Az edzésnek valid képpel kell rendelkeznie!");

                if(training.MaxParticipant == 0)
                    return BadRequest("Az edzésnek legalább 1 résztvevővel kell rendelkeznie!");

                if(dbContext.Trainings.Any(t => t.StartTime < training.EndTime && training.StartTime < t.EndTime))
                    return BadRequest("Ebben az időintervallumban már van regisztrált edzés!");

                Training createdTraining = new Training()
                {
                    Name = training.Name,
                    Description = training.Description,
                    Image = training.Image,
                    StartTime = training.StartTime,
                    EndTime = training.EndTime,
                    MaxParticipant = training.MaxParticipant,
                    TrainerId = id,
                    Active = true,
                };

                dbContext.Trainings.Add(createdTraining);
                dbContext.SaveChanges();
                Training dbTraining = dbContext.Trainings.Include(t=>t.Trainer).First(t => t.Id == createdTraining.Id);



                return Ok(new
                {
                    message = "Az edzés sikeresen regisztrálva lett!",
                    training = new
                    {
                        dbTraining.Id,

                        dbTraining.Name,
                        dbTraining.Description,
                        dbTraining.Image,
                        dbTraining.StartTime,
                        dbTraining.EndTime,
                        dbTraining.MaxParticipant,

                        dbTraining.TrainerId,

                        trainer = new
                        {
                            dbTraining.Trainer.Id,
                            dbTraining.Trainer.Name
                        }
                    }
                });
            });
        }
    }
}
