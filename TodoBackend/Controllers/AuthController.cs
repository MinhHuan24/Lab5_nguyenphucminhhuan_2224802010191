using Microsoft.AspNetCore.Mvc;
using TodoBackend.Data;
using TodoBackend.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.IdentityModel.Tokens;
using System.Text;

namespace TodoBackend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly IConfiguration _config;

    public AuthController(AppDbContext context, IConfiguration config)
    {
        _context = context;
        _config = config;
    }

    // Đăng ký tài khoản
    [HttpPost("register")]
    public IActionResult Register(User user)
    {
        // Kiểm tra dữ liệu đầu vào
        if (string.IsNullOrWhiteSpace(user.Email) ||
            string.IsNullOrWhiteSpace(user.Password))
        {
            return BadRequest("Email and Password are required");
        }

        // Kiểm tra email đã tồn tại
        if (_context.Users.Any(x => x.Email == user.Email))
        {
            return BadRequest("Email already exists");
        }

        // Tạo user mới
        var newUser = new User
        {
            Email = user.Email,
            Password = user.Password
        };

        _context.Users.Add(newUser);
        _context.SaveChanges();

        return Ok(new
        {
            message = "Register successful"
        });
    }

    // Đăng nhập
    [HttpPost("login")]
    public IActionResult Login(User login)
    {
        // Kiểm tra input
        if (string.IsNullOrWhiteSpace(login.Email) ||
            string.IsNullOrWhiteSpace(login.Password))
        {
            return BadRequest("Email and Password are required");
        }

        // Tìm user
        var user = _context.Users
            .FirstOrDefault(x =>
                x.Email == login.Email &&
                x.Password == login.Password);

        // Sai tài khoản
        if (user == null)
        {
            return Unauthorized("Invalid email or password");
        }

        // Claims
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Email, user.Email)
        };

        // JWT Key
        var jwtKey = _config["Jwt:Key"];

        if (string.IsNullOrWhiteSpace(jwtKey))
        {
            return StatusCode(500, "JWT Key is missing in configuration");
        }

        // Key tối thiểu nên dài
        var key = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(jwtKey));

        // Credentials
        var creds = new SigningCredentials(
            key,
            SecurityAlgorithms.HmacSha256);

        // Token
        var token = new JwtSecurityToken(
            issuer: null,
            audience: null,
            claims: claims,
            expires: DateTime.Now.AddDays(1),
            signingCredentials: creds
        );

        // Trả token
        return Ok(new
        {
            message = "Login successful",
            token = new JwtSecurityTokenHandler()
                .WriteToken(token)
        });
    }
}