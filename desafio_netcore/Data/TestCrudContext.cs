using desafio_netcore.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations.Schema;

namespace desafio_netcore
{
    public class TestCrudContext : DbContext
    {
        public TestCrudContext(DbContextOptions<TestCrudContext> options) : base(options) {}

        public DbSet<User> Users { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            UserMappings(modelBuilder);
            RolMappings(modelBuilder);
        }

        private void UserMappings(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<User>().ToTable("tUsers");

            modelBuilder.Entity<User>().Property(x => x.ID).HasColumnName("cod_usuario");
            modelBuilder.Entity<User>().Property(x => x.Username).HasColumnName("txt_user");
            modelBuilder.Entity<User>().Property(x => x.Password).HasColumnName("txt_password");
            modelBuilder.Entity<User>().Property(x => x.Name).HasColumnName("txt_nombre");
            modelBuilder.Entity<User>().Property(x => x.Lastname).HasColumnName("txt_apellido");
            modelBuilder.Entity<User>().Property(x => x.Document).HasColumnName("nro_doc");
            modelBuilder.Entity<User>().Property(x => x.Active).HasColumnName("sn_activo");
            modelBuilder.Entity<User>().Property(x => x.CodigoRol).HasColumnName("cod_rol");

            modelBuilder.Entity<User>()
               .HasOne(x => x.Rol)
               .WithMany(x => x.Users)
               .HasForeignKey(x => x.CodigoRol)
               .HasPrincipalKey(x => x.ID)
               .HasConstraintName("FK_Users_Rol");
        }

        private void RolMappings(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Rol>().ToTable("tRol");

            modelBuilder.Entity<Rol>().Property(x => x.ID).HasColumnName("cod_rol");
            modelBuilder.Entity<Rol>().Property(x => x.Description).HasColumnName("txt_desc");
            modelBuilder.Entity<Rol>().Property(x => x.Active).HasColumnName("sn_activo");
        }
    }
}
