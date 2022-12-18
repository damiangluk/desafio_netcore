using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace desafio_netcore.Models
{
    public class User : Identity
    {
        public User(string username, string password, string name, string lastname, string document, int active)
        {
            Username = username;
            Password = password;
            Name = name;
            Lastname = lastname;
            Document = document;
            Active = active;
        }

        public string Username { get; set; }
        public string Password { get; set; }
        public string Name { get; set; }
        public string Lastname { get; set; }
        public string Document { get; set; }
        public int Active { get; set; }
        public int CodigoRol { get; set; }
        public Rol Rol { get; set; }
    }
}