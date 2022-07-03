import os
from typing import List

from dotenv import load_dotenv

from lib.download import downloadFiles
from lib.extract import extractTars

load_dotenv()

linux_version = os.environ.get('LINUX_VERSION', '5.10.128')
download_dir = os.path.join(os.getcwd(), 'download')
build_folder = os.path.join(os.getcwd(), 'build')

sources = [
    f"https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-{linux_version}.tar.xz"
]


def downloadSources(sources: List[str]):
    return [{
        'path': path,
        'filename': os.path.basename(path)
    } for path in downloadFiles(sources, download_dir, True)]


def extractSources(arquives):
    return [{
        'path': path,
        'dirname': os.path.basename(path)
    } for path in extractTars([arquive['path'] for arquive in arquives], build_folder, True)]


arquives = downloadSources(sources)
sources = extractSources(arquives)

print(arquives)
print(sources)
