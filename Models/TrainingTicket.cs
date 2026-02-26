using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace GymTracer.models;

public partial class TrainingTicket : ModelBase<TrainingTicket> 
{
    public long Id { get; set; }

    [Required]
    public long TrainingId { get; set; }

    [Required]
    public long TicketId { get; set; }

    public virtual Ticket Ticket { get; set; } = null!;

    public virtual Training Training { get; set; } = null!;
}
