using System;
using System.IO;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace fieldap_api_dotnet
{
    class Program
    {
        static void Main(string[] args)
        {
            string fieldAPendpoint = "https://app.backend.fieldap.com/API",
                   fieldAPapiToken = "YOUR-TOKEN";

            try
            {
                var rez = Task.Run(async () =>
                {
                    string url = $"{fieldAPendpoint}/v1.5/connections";
                    using (var httpClient = new HttpClient())
                    {
                        httpClient.DefaultRequestHeaders.Add("token", fieldAPapiToken);
                        var httpResponse = await httpClient.GetAsync(url);
                        var httpContent = await httpResponse.Content.ReadAsStringAsync();
                        
                        int statusCode = (int)httpResponse.StatusCode;
                        if (statusCode != 200)
                        {
                            throw new Exception($"{statusCode}, {httpContent}");
                        }

                        return httpContent;
                    }
                });
            
                var result = JArray.Parse(rez.Result);
                using(StreamWriter file = new StreamWriter("connections.csv"))
                {
                    file.WriteLine("category;name;symbol");
                    foreach (var r in result)
                    {
                        file.WriteLine($"{r["category"]};{r["name"]};{r["symbol"]}");
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }
    }
}
