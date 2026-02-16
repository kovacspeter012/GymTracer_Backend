using GymTracer.models;
using Microsoft.EntityFrameworkCore;

namespace GymTracer.Context
{
    public partial class GymTracerDbContext : DbContext
    {
        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                var connectionstring = System.Configuration.ConfigurationManager.AppSettings["ConnectionString"];
                if (connectionstring == null)
                {
                    throw new Exception("No connectionstring set");
                }
                optionsBuilder.UseMySQL(connectionstring);
            }

        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            
        }
    }
}
