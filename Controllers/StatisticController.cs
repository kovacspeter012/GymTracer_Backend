using GymTracer.Auth;
using GymTracer.Context;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

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


    }
}
