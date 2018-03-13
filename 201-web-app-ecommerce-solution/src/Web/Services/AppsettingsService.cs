using Microsoft.Extensions.Configuration;

namespace Microsoft.eShopWeb.Services
{
    public class AppSettingsService : IAppsettingsService
    {
        public static IConfiguration Configuration { get; set; }

        public AppSettingsService(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public string getValue(string Key)
        {
            return Configuration[Key];
        }
    }
}
