from typing import List


def downloadFile(url: str, path: str, progress: bool = False):
  """
  Downloads a file with the http protocol with the requests python library

  Arguments:
    url: http url string where the file will be requested | "https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-VERSION.tar.xz"
    path: directory string where the file will be saved   | "/home/USER/Downloads"
    progress: boolean to show or hide progress bar        | True
  Returns:
    The complete file path string                         | "/home/USER/Downloads/linux-VERSION.tar.xz"
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

def downloadFiles(urls: List[str], path: str, progress: bool):
  """
  Downloads all files in a list with the http protocol with the requests python library

  Arguments:
    url: http url list of strings where the files will be requested | ["https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-VERSION.tar.xz", "https://ftp.gnu.org/gnu/glibc/glibc-VERSION.tar.xz"]
    path: directory string where the files will be saved            | "/home/USER/Downloads"
    progress: boolean to show or hide progress bar                  | True
  Returns:
    A list with all the complete file path string in order          | ["/home/USER/Downloads/linux-VERSION.tar.xz", "/home/USER/Downloads/glibc-VERSION.tar.xz"]
  """

  return [downloadFile(url, path, progress) for url in urls]

if __name__ == '__main__':
  import os
  url_list = [
    "https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.52.tar.xz",
    "https://ftp.gnu.org/gnu/glibc/glibc-2.35.tar.xz"
  ]
  help(downloadFile)
  help(downloadFiles)
  print(downloadFiles(url_list, os.path.join(os.getcwd(), 'download-test'), True))
