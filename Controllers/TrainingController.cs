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
                List<Training> trainings = 
                    dbContext.Trainings.Include(t => t.Trainer)
                                       .Where(t => t.TrainerId == id && t.Active)
                                       .OrderByDescending(t=> t.EndTime)
                                       .ToList();

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

                // trainingId 0, mert új, és még nincs id-je
                if(ProblemWithValidatingTraining(training, true, id, userId, 0, userRole) is string problem)
                    return BadRequest(problem);

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

        [HttpPut("{training_id}")]
        public IActionResult UpdateTraining([FromRoute] long training_id, [FromBody] dynamic body)
        {
            return this.Run(() =>
            {
                Training training = Training.Deserialize(body);

                string? userId = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
                string? userRole = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Role)?.Value;
                if (userId is null || userRole is null)
                    return BadRequest("Hibás token!");

                Training? dbTraining = dbContext.Trainings.FirstOrDefault(t => t.Id == training_id && t.Active);

                if (dbTraining is null)
                    return BadRequest("Nincs ilyen edzés!");

                // Ellenőrzi: dbTraining.TrainerId == userId
                if (ProblemWithValidatingTraining(training, false, dbTraining.TrainerId, userId, training_id, userRole) is string problem)
                    return BadRequest(problem);

                if (training.TrainerId == 0)
                {
                    training.TrainerId = dbTraining.TrainerId;
                }

                if(dbTraining.TrainerId != training.TrainerId)
                {
                    if (userRole != nameof(User_Role.admin) && userRole != nameof(User_Role.staff)) 
                        return BadRequest("Az edzést nem adhatja át másnak.");
                }

                dbTraining.Name = training.Name;
                dbTraining.Description = training.Description;
                dbTraining.Image = training.Image;
                dbTraining.StartTime = training.StartTime;
                dbTraining.EndTime = training.EndTime;
                dbTraining.MaxParticipant = training.MaxParticipant;
                dbTraining.TrainerId = training.TrainerId;

                dbContext.SaveChanges();
                return Ok(new
                {
                    message = "Az edzés sikeresen módosítva lett!",
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

        [NonAction]
        public string? ProblemWithValidatingTraining(Training training, bool isCreate, long id, string userId, long trainingId, string userRole)
        {
            string apiActionText = isCreate ? "hozhat létre" : "módosíthat";

            if (userId != id.ToString())
            {
                if (userRole != nameof(User_Role.admin) && userRole != nameof(User_Role.staff))
                    return $"Csak saját nevében {apiActionText} edzést!";

                User? selectedUser = dbContext.Users.FirstOrDefault(u => u.Id == id);
                if (selectedUser is null)
                    return "Nincs ilyen felhasználó!";
            }

            TimeSpan trainingTimeSpan = training.EndTime - training.StartTime;
            if (training.StartTime < tokenHandler.Now() || training.EndTime < tokenHandler.Now())
                return "Az edzés időpontja érvénytelen!";

            if (trainingTimeSpan.TotalMinutes < 5)
                return "Az edzés időtartama legalább 5 perc kell legyen!";
            else if (trainingTimeSpan.TotalHours > 2)
                return "Az edzés időtartama legfeljebb 2 óra lehet!";

            if (string.IsNullOrEmpty(training.Name) || training.Name.Trim() == "")
                return "Az edzésnek valid névvel kell rendelkeznie!";

            if (string.IsNullOrEmpty(training.Description) || training.Description.Trim() == "")
                return "Az edzésnek valid leírással kell rendelkeznie!";

            // TODO: Feltöltött kép validáció
            if (string.IsNullOrEmpty(training.Image) || training.Image.Trim() == "")
                return "Az edzésnek valid képpel kell rendelkeznie!";

            if (training.MaxParticipant == 0)
                return "Az edzésnek legalább 1 résztvevővel kell rendelkeznie!";

            if (dbContext.Trainings.Any(t => t.Active && t.StartTime < training.EndTime && training.StartTime < t.EndTime && t.Id != trainingId))
                return "Ebben az időintervallumban már van regisztrált edzés!";

            return null;
        }
    }
}
