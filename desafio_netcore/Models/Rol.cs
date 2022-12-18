using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using System.Text.Json;

namespace desafio_netcore.Models
{
    public class Rol : Identity
    {
        public Rol(string description, int active)
        {
            Description = description;
            Active = active;
        }

        public string Description { get; set; }
        public int Active { get; set; }
        public ICollection<User> Users { get; set; }
    }

    public enum Roles
    {
        Administrator = 1,
        Cliente = 2
    }

    public class RolPermissions : ActionFilterAttribute
    {
        private Roles Rol;
        public RolPermissions(Roles rol)
        {
            Rol = rol;
        }

        public override void OnActionExecuting(ActionExecutingContext context)
        {
            if (!string.IsNullOrEmpty(context.HttpContext.Session.GetString("user")))
            {
                User user = JsonSerializer.Deserialize<User>(context.HttpContext.Session.GetString("user"));

                if(user.CodigoRol > (int)Rol)
                {
                    context.Result = new RedirectResult("~/Home/PermissionError");
                }
            }

            base.OnActionExecuting(context);
        }
    }
}
