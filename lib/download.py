def downloadFile(url: str, path: str):
  from requests import get
  import os

  if os.path.isfile(path):
    raise Exception("Path cannot be a File")

  if not os.path.exists(path):
    os.makedirs(path)

  filename = url.split("/")[-1]
  with get(url) as response:
    with open(os.path.join(path, filename), 'wb') as file:
      file.write(response.content)

  return os.path.join(path, filename)

if __name__ == '__main__':
  import os
  print(downloadFile('https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.52.tar.xz', os.path.join(os.getcwd(), 'test')))