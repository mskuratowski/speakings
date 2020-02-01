using System.Text;
using System.Threading.Tasks;
using Functions.Configurations;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Devices;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Functions
{
    public class DevKitTranslatorFunction
    {
        private readonly SpeechConfiguration _speechConfiguration;

        public DevKitTranslatorFunction(IOptions<SpeechConfiguration> speechConfiguration)
        {
            _speechConfiguration = speechConfiguration.Value;
        }

        [FunctionName("devkit_translator")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            string fromLanguage = req.Query["source"];
            if (string.IsNullOrEmpty(fromLanguage))
            {
                return new BadRequestObjectResult("Please pass a 'source' on the query string to specify the from language.");
            }
            log.LogInformation($"Source language: {fromLanguage}");

            var speechTranslation = new SpeechTranslation(_speechConfiguration.SpeechSubscriptionKey, _speechConfiguration.SpeechServiceRegion, log);
            string result = await speechTranslation.TranslationWithAudioStreamAsync(req.Body, fromLanguage);
            log.LogInformation("Translation result: " + result);

            // Send translation result as C2D message
            string iothubConnectionString = System.Environment.GetEnvironmentVariable("iotHubConnectionString");
            var serviceClient = ServiceClient.CreateFromConnectionString(iothubConnectionString);
            var commandMessage = new Message(Encoding.ASCII.GetBytes(result));
            await serviceClient.SendAsync(_speechConfiguration.DeviceName, commandMessage);

            if (result != null)
            {
                return new OkObjectResult("Translation result: " + result);
            }
            else
            {
                return new BadRequestObjectResult("Failed to translate speech.");
            }
        }
    }
}
