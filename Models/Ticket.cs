using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace GymTracer.models;

public enum Ticket_Type
{
    training,
    daily,
    monthly,
    x_usage
}

public partial class Ticket : ModelBase<Ticket>
{
    public long Id { get; set; }

    [Required]
    public Ticket_Type Type { get; set; }

    [Required]
    public string Description { get; set; } = null!;

    [Required]
    public bool IsStudent { get; set; }

    [Required]
    public ulong Price { get; set; }

    [Required]
    [Column(TypeName = "decimal(5, 2) unsigned")]
    public decimal Tax_key { get; set; }

    public ulong? MaxUsage { get; set; }

    public virtual ICollection<TrainingTicket> TrainingTickets { get; set; } = new List<TrainingTicket>();

    public virtual ICollection<UserTicket> UserTickets { get; set; } = new List<UserTicket>();
}
