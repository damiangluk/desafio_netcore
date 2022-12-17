using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace desafio_netcore.Models
{
    public class Rol
    {
        public Rol(string description, int active)
        {
            Description= description;
            Active= active;
        }

        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int ID { get; set; }
        public string Description{ get; set; }
        public int Active { get; set; }
        public ICollection<User> Users { get; set; }
    }
}