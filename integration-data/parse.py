from urllib.request import urlopen
import json

hashes = {}

with open('metadata.out.txt') as f:
  while f.readable():
    id = f.readline()
    uri = f.readline()
    data = None
    with urlopen(uri) as response:
        data = json.loads(response.read())
        if data['properties']['btc transaction hash'] in hashes:
           raise RuntimeError('bad duplicate')
        hashes[data['properties']['btc transaction hash']] = True
    print(f'{id} {data}')