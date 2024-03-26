using Microsoft.Extensions.Configuration;
using Microsoft.Identity.Client;
using System.Reflection;
using System.Windows;

namespace EntraDemo
{
    /// <summary>
    /// Interaction logic for App.xaml
    /// </summary>
    public partial class App : Application
    {
        static App()
        {
            CreateApplication();
        }

        public static void CreateApplication()
        {
            var assembly = Assembly.GetExecutingAssembly();
            using var stream = assembly.GetManifestResourceStream("EntraDemo.appsettings.json");
            AppConfiguration = new ConfigurationBuilder()
                .AddJsonStream(stream)
                .Build();

            AzureAdConfig azureADConfig = AppConfiguration.GetSection("AzureAd").Get<AzureAdConfig>();

            BrokerOptions options = new BrokerOptions(BrokerOptions.OperatingSystems.Windows);
            options.Title = "EntraDemo";
            

            var builder = PublicClientApplicationBuilder.Create(azureADConfig.ClientId)

                .WithAuthority(AzureCloudInstance.AzurePublic, azureADConfig.Tenant)

                .WithBroker(options)
                
                .WithRedirectUri("ms-appx-web://microsoft.aad.brokerplugin/<<App registration client ID>>");

            _clientApp = builder.Build();
        }

        private static IPublicClientApplication _clientApp;
        private static IConfiguration AppConfiguration;
        public static IPublicClientApplication PublicClientApp { get { return _clientApp; } }
    }

}
