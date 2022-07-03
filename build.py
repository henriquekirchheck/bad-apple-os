import json
import os

from lib.download import downloadFile
from lib.extract import extractTar

with open(os.path.join(os.getcwd(), 'info.json')) as info:
    data = json.load(info)

download_dir = os.path.join(os.getcwd(), 'download')
build_dir = os.path.join(os.getcwd(), 'build')


def downloadData(data):
    for package, info in data.items():
        data[package]["filePath"] = downloadFile(
            info["url"].replace('[VERSION]', info['version']), download_dir, True)


def extractData(data):
    for package, info in data.items():
        data[package]["buildDir"] = extractTar(
            info["filePath"], build_dir, True)


downloadData(data)
extractData(data)
print(data)
