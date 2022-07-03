import os
import json
from typing import List

from lib.download import downloadFiles
from lib.extract import extractTars

with open(os.path.join(os.getcwd(), 'info.json')) as info:
    data = json.load(info)

linux_version = data['linux-version']
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
