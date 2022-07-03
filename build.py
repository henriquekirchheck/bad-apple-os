import os

from dotenv import load_dotenv

from lib.download import downloadFiles

load_dotenv()

linux_version = os.environ.get('LINUX_VERSION', '5.10.128')
download_folder = os.path.join(os.getcwd(), 'download')


def downloadSources():
    sources = [
        f"https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-{linux_version}.tar.xz"
    ]

    return [{
        'path': path,
        'filename': os.path.basename(path)
    } for path in downloadFiles(sources, download_folder, True)]


arquives = downloadSources()
print(arquives)
