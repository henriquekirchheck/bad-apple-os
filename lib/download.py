def downloadFile(url: str, path: str, progress: bool = False):
  """
  Downloads a file with the http protocol with the requests python library

  Arguments:
    url: http url string where file will be requested | "https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.52.tar.xz"
    path: directory string where file will be saved   | "/home/USER/Downloads"
    progress: boolean to show or hide progress bar    | True
  Returns:
    The complete file path string                     | "/home/USER/Downloads/linux-5.15.52.tar.xz"
  """

  import os
  import shutil

  from requests import get
  from tqdm.auto import tqdm

  if os.path.isfile(path):
    raise Exception("Path cannot be a File")

  if not os.path.exists(path):
    os.makedirs(path)

  filename = url.split("/")[-1]

  if progress:
    with get(url, stream=True) as res:
      total_length = int(res.headers.get("Content-Length"))

      with tqdm.wrapattr(res.raw, "read", total=total_length, desc=f"Downloading {filename}") as raw:
        with open(os.path.join(path, filename), 'wb') as file:
          shutil.copyfileobj(raw, file)
  else:
    with get(url) as response:
      with open(os.path.join(path, filename), 'wb') as file:
        file.write(response.content)

  return os.path.join(path, filename)

if __name__ == '__main__':
  import os
  help(downloadFile)
  print(downloadFile('https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.52.tar.xz', os.path.join(os.getcwd(), 'download-test'), False))
