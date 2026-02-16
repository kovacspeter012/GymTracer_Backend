using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace GymTracer.models;

public partial class Token
{
    public long Id { get; set; }

    [Required]
    public long UserId { get; set; }

    [Required]
    public DateTime CreatedAt { get; set; }

    public DateTime? RevokedAt { get; set; }

    [Required]
    public string Token1 { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
