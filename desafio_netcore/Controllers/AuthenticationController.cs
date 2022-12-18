using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using desafio_netcore.Models;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace desafio_netcore.Controllers
{
    [AllowAnonymous]
    public class AuthenticationController : Controller
    {
        private readonly TestCrudContext _context;

        public AuthenticationController(TestCrudContext context)
        {
            _context = context;
        }

        public async Task<IActionResult> Index()
        {
            return RedirectToAction("Login");
        }

        public async Task<IActionResult> Login()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Login(string Username, string Password)
        {
            var user = await _context.Users
                .Include(u => u.Rol)
                .AsNoTracking()
                .FirstOrDefaultAsync(m => m.Username == Username && m.Password == Password && m.Active > 0);
            if (user != null)
            {
                await SetCookie(user);
                user.Rol.Users = null;
                HttpContext.Session.SetString("user", JsonSerializer.Serialize(user, new JsonSerializerOptions { ReferenceHandler = ReferenceHandler.Preserve }));
                return RedirectUser(user);
            }

            return View();
        }


        public async Task<IActionResult> Logout()
        {
            await HttpContext.SignOutAsync();
            HttpContext.Session.SetString("user", "");
            return RedirectToAction("Login");
        }

        private async Task SetCookie(User? user)
        {
            var claims = new List<Claim>
                {
                    new Claim(ClaimTypes.NameIdentifier, user.ID.ToString()),
                    new Claim(ClaimTypes.Role, user.Rol.Description),
                };
            var identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
            var principal = new ClaimsPrincipal(identity);
            await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, new ClaimsPrincipal(principal));
        }

        private RedirectToActionResult RedirectUser(User user)
        {
            if (user.Rol.ID == (int)Roles.Administrator)
                return RedirectToAction("Index", "Users");
            return RedirectToAction("Index", "Home");
        }
    }
}
