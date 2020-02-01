using Functions;
using Functions.Configurations;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

[assembly: FunctionsStartup(typeof(Startup))]
namespace Functions
{
    public class Startup : FunctionsStartup
    {
        public override void Configure(IFunctionsHostBuilder builder)
        {
            builder.Services.AddOptions<SpeechConfiguration>()
                .Configure<IConfiguration>((options, configuration) => configuration.GetSection("SpeechConfiguration").Bind(options));
        }
    }
}