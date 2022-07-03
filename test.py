import os

from dotenv import load_dotenv

from lib.download import downloadFiles

load_dotenv()

linux_version = os.environ.get('LINUX_VERSION', '5.10.128')
build_folder = os.path.join(os.getcwd(), 'build')

sources = [
  f"https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-{linux_version}.tar.xz"
]

arquives = [{
  'path': path,
  'filename': os.path.basename(path)
} for path in downloadFiles(sources, build_folder, True)]

print(arquives)
