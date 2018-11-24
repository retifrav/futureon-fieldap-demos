import sys
import time
import json
import requests

fieldAPendpoint = "https://app.backend.fieldap.com/API"
fieldAPapiToken = "YOUR-TOKEN"

reqURL = fieldAPendpoint + "/v1.5/connections"
reqHeaders = {"token": fieldAPapiToken}
req = requests.get(reqURL, headers = reqHeaders)

if (req.status_code == 200):
    result = json.loads(req.content.decode('utf-8'))
    with open("connections.csv", "w") as csv:
        print("category;name;symbol", file=csv)
        for r in result:
            print(f"{r['category']};{r['name']};{r['symbol']}", file=csv)
else:
    sys.stderr.write("Error: " + str(req.status_code) + ", " + req.content.decode("utf-8"))
    sys.exit(1)
