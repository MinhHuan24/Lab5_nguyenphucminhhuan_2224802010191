using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TodoBackend.Data;
using TodoBackend.Models;
using System.Security.Claims;

namespace TodoBackend.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TodoController : ControllerBase
{
    private readonly AppDbContext _context;

    public TodoController(AppDbContext context)
    {
        _context = context;
    }

    // Lấy danh sách Todo theo user
    [HttpGet]
    public IActionResult Get()
    {
        var claim = User.FindFirst(ClaimTypes.NameIdentifier);

        if (claim == null)
            return Unauthorized();

        var userId = int.Parse(claim.Value);

        var todos = _context.Todos
            .Where(t => t.UserId == userId)
            .ToList();

        return Ok(todos);
    }

    // Thêm Todo
    [HttpPost]
    public IActionResult Add(TodoItem todo)
    {
        var claim = User.FindFirst(ClaimTypes.NameIdentifier);

        if (claim == null)
            return Unauthorized();

        var userId = int.Parse(claim.Value);

        todo.UserId = userId;

        _context.Todos.Add(todo);
        _context.SaveChanges();

        return Ok(new
        {
            message = "Todo added successfully"
        });
    }

    // Xóa Todo
    [HttpDelete("{id}")]
    public IActionResult Delete(int id)
    {
        var claim = User.FindFirst(ClaimTypes.NameIdentifier);

        if (claim == null)
            return Unauthorized();

        var userId = int.Parse(claim.Value);

        var todo = _context.Todos
            .FirstOrDefault(t =>
                t.Id == id &&
                t.UserId == userId);

        if (todo == null)
            return NotFound("Todo not found");

        _context.Todos.Remove(todo);
        _context.SaveChanges();

        return Ok(new
        {
            message = "Todo deleted successfully"
        });
    }
}