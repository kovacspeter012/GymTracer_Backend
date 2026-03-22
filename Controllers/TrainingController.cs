using GymTracer.Auth;
using GymTracer.Context;
using GymTracer.DataValidator;
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
                var trainings = dbContext.Trainings.Where(t => t.TrainerId == id && t.Active)
                                                   .OrderByDescending(t => t.EndTime);

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
                    },
                    tickets = t.Tickets.Where(ticket => ticket.IsActive).Select(ticket => new
                        {
                        ticket.Id,

                        ticket.Description,
                        ticket.IsStudent,
                        ticket.Type,
                        ticket.Price,
                        ticket.Tax_key,

                        ticket.MaxUsage,
                        ticket.IsActive
                        })
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

                if (userId != id.ToString())
                    if (userRole != nameof(User_Role.admin) && userRole != nameof(User_Role.staff))
                        return BadRequest("Csak saját nevedben készíthetsz edzést!");

                var ValidatorResult = ValidateTraining(training);
                if (!ValidatorResult.IsValid)
                    return BadRequest(new { ValidatorResult.Errors });

                if (dbContext.Trainings.Any(t => t.Active && t.StartTime < training.EndTime && training.StartTime < t.EndTime))
                    return BadRequest("Ebben az időintervallumban már van regisztrált edzés!");

                User? dbTrainer = dbContext.Users.FirstOrDefault(u => u.Id == id);

                if(dbTrainer is null)
                    return BadRequest("Nincs ilyen felhasználó!");

                Training dbTraining = new Training()
                {
                    Name = training.Name,
                    Description = training.Description,
                    Image = training.Image,
                    StartTime = training.StartTime,
                    EndTime = training.EndTime,
                    MaxParticipant = training.MaxParticipant,
                    TrainerId = dbTrainer.Id,
                    Active = true,
                    Tickets = new List<Ticket>()
                };

                var TicketValidatorResult = ValidateTickets(training.Tickets);
                if (!TicketValidatorResult.IsValid)
                    return BadRequest(new { TicketValidatorResult.Errors });

                // Training Ticketjeinek létrehozása (ha meg lettek adva)
                foreach (Ticket ticket in training.Tickets)
                {
                    dbTraining.Tickets.Add(new Ticket()
                    {
                        Description = ticket.Description,
                        IsStudent = ticket.IsStudent,
                        Price = ticket.Price,
                        Type = ticket.Type,
                            MaxUsage = 1,
                            Tax_key = 27,
                        IsActive = true
                    });
                }

                dbContext.Trainings.Add(dbTraining);
                dbContext.SaveChanges();

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
                            dbTrainer.Id,
                            dbTrainer.Name
                        },
                        tickets = dbTraining.Tickets.Where(t => t.IsActive).Select(ticket => new
                        {
                            ticket.Id,

                            ticket.Description,
                            ticket.IsStudent,
                            ticket.Type,
                            ticket.Price,
                            ticket.Tax_key,

                            ticket.MaxUsage,
                            ticket.IsActive
                        })
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

        [HttpDelete("{training_id}")]
        public IActionResult DeleteTraining([FromRoute] long training_id)
        {
            return this.Run(() =>
            {
                string? userId = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
                string? userRole = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Role)?.Value;
                if (userId is null || userRole is null)
                    return BadRequest("Hibás token!");

                Training? dbTraining = dbContext.Trainings.FirstOrDefault(t => t.Id == training_id && t.Active);

                if (dbTraining is null)
                    return BadRequest("Nincs ilyen edzés!");

                if (userId != dbTraining.TrainerId.ToString())
                {
                    if (userRole != nameof(User_Role.admin) && userRole != nameof(User_Role.staff))
                        return BadRequest("Csak saját nevében törölheti az edzést!");
                }

                dbTraining.Active = false;
                dbContext.SaveChanges();

                return Ok(new
                {
                    message = "Az edzés sikeresen törölve lett!"
                });
            });
        }

        [HttpPatch("{training_id}/user/{id}/presence")]
        public IActionResult SetTrainingPresence([FromRoute] long training_id, [FromRoute] long id, [FromBody] dynamic body)
        {
            return this.Run(() =>
            {
                string? userId = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
                string? userRole = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Role)?.Value;
                if (userId is null || userRole is null)
                    return BadRequest("Hibás token!");

                Training? dbTraining = 
                    dbContext.Trainings.Include(t => t.TrainingUsers)
                                       .FirstOrDefault(t => t.Id == training_id && t.Active);

                if (dbTraining is null)
                    return BadRequest("Nincs ilyen edzés!");

                bool? presence = body.presence;

                if(presence is null)
                    return BadRequest("A részvétel megadása kötelező!");

                if (userId != dbTraining.TrainerId.ToString())
                {
                    if (userRole != nameof(User_Role.admin) && userRole != nameof(User_Role.staff))
                        return BadRequest("Csak saját edzéséhez állíthatja az emberek jelenlétét!");
                }

                TrainingUser? dbTrainingUser = dbTraining.TrainingUsers.FirstOrDefault(t => t.UserId == id);
                if (dbTrainingUser is null) 
                    return BadRequest("Ez a felhasználó nincs regisztrálva erre az edzésre!");

                dbTrainingUser.Presence = presence.Value;
                dbContext.SaveChanges();

                return Ok(new{ 
                    Message = "A részvétel sikeresen módosítva lett!",
                    dbTrainingUser.TrainingId,
                    dbTrainingUser.UserId,
                    dbTrainingUser.Presence
                });
            });
        }

        [NonAction]
        public Validator<Training> ValidateTraining(Training training)
        {
            var trainingValidator = Validator.Create(training);

            trainingValidator.Validate(t => t.StartTime, "edzés kezdete")
                .NotDefault()
                .After(DateTime.UtcNow)
                .Before(DateTime.UtcNow.AddMonths(1));

            trainingValidator.Validate(t => t.EndTime, "edzés vége")
                .NotDefault()
                .After(training.StartTime)
                .Before(DateTime.UtcNow.AddMonths(1));

            // Edzés hossza
            trainingValidator.Validate(t =>
              (t.EndTime - t.StartTime).TotalMinutes,
              "edzés időtartalma", "StartTime")
                .Between(5, 2 * 60);

            trainingValidator.Validate(t => t.Name, "edzés név")
                .NotNullOrEmpty();

            trainingValidator.Validate(t => t.Description, "edzés leírás")
                .NotNullOrEmpty();

            trainingValidator.Validate(t => t.Image, "edzés kép")
                .NotNullOrEmpty();

            trainingValidator.Validate(t => t.MaxParticipant, "résztvevő szám")
                .GreaterThan(0ul)
                .LessThan(100ul);

            return trainingValidator;
        }

        [NonAction]

        public Validator<ICollection<TrainingTicket>> ValidateTickets(ICollection<TrainingTicket> trainingTickets)
        {
            var trainingTicketsValidator = Validator.Create(trainingTickets);
            trainingTicketsValidator.Validate(t => t, "TrainingTickets", "TrainingTickets")!
                .ForEach(trainingTicket =>
        {
                    var TicketValidatorChain = trainingTicket.ThenValidate(tt => tt.Ticket, "jegy")
                                                             .NotNull();

                    TicketValidatorChain.ThenValidate(ticket => ticket.Description, "jegy leírás")
                        .NotNullOrEmpty();

                    TicketValidatorChain.ThenValidate(ticket => ticket.Price, "jegy ár")
                        .Min(0ul)
                        .Max(ulong.MaxValue);

                    TicketValidatorChain.ThenValidate(ticket => ticket.Type, "jegy típus")
                        .InEnum();
                });

            return trainingTicketsValidator;
        }
    }
}
