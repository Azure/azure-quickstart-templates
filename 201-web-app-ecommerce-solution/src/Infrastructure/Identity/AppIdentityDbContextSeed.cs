using Microsoft.AspNetCore.Identity;
using System.Threading.Tasks;
using System.Linq;

namespace Infrastructure.Identity
{
    public class AppIdentityDbContextSeed
    {
        public static async Task SeedAsync(UserManager<ApplicationUser> userManager)
        {
            if (!userManager.Users.Any())
            {
                var defaultUser = new ApplicationUser { UserName = "demouser@microsoft.com", Email = "demouser@microsoft.com" };
                await userManager.CreateAsync(defaultUser, "Pass@word1");
            }
        }
    }
}
