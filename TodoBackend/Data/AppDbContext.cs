using Microsoft.EntityFrameworkCore;
using TodoBackend.Models;

namespace TodoBackend.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options)
    {
    }

    public DbSet<User> Users { get; set; }

    public DbSet<TodoItem> Todos { get; set; }
}