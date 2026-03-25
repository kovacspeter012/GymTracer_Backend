using GymTracer.Auth;
using GymTracer.Context;
using GymTracer.Exceptions;
using GymTracer.Extensions;
using GymTracer.models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Globalization;

namespace GymTracer.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class StatisticController : ControllerBase
    {
        private readonly GymTracerDbContext DbContext;
        private readonly TokenHandler tokenHandler;

        public StatisticController(GymTracerDbContext dbContext, TokenHandler tokenHandler)
        {
            this.DbContext = dbContext;
            this.tokenHandler = tokenHandler;
        }

        [HttpGet("gym")]
        public IActionResult GetAttendanceStatistics([FromQuery] uint daysBack, [FromQuery] uint weeksBack)
        {
            return this.Run(() =>
            {
                if (daysBack > 7)
                {
                    throw new ApiException(400, "Only 7 days back statistic allowed at max");
                }

                if (weeksBack > 4)
                {
                    throw new ApiException(400, "Only 4 weeks back statistic allowed at max");
                }

                List<UsageLog> dayByStatistics = DbContext.Set<UsageLog>().Where(ul => ul.UseDate < tokenHandler.Now() && ul.UseDate > tokenHandler.Now().AddDays(-daysBack)).ToList();
                var dayBackReturn = dayByStatistics.GroupBy(s => s.UseDate.Date).Select(g => new
                {
                    date = g.Key.ToString("yyyy.MM.dd"),
                    guestNumber = g.Count()
                });

                List<UsageLog> weekByStatistics = DbContext.Set<UsageLog>().Where(ul => ul.UseDate < tokenHandler.Now() && ul.UseDate > tokenHandler.Now().AddDays(-weeksBack * 7)).ToList();
                var weekBackReturn = weekByStatistics.GroupBy(s => GetStartOfWeek(s.UseDate, DayOfWeek.Monday)).Select(g => new
                {
                    startOfWeek = g.Key,
                    guestNumber = g.Count()
                });

                return StatusCode(200, new { dayBackReturn, weekBackReturn });
            });
        }
        [NonAction]
        public DateTime GetStartOfWeek(DateTime dt, DayOfWeek startOfWeek)
        {
            int diff = (7 + (dt.DayOfWeek - startOfWeek)) % 7;
            return dt.Date.AddDays(-1 * diff);
        }
    }
}
