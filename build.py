import json
import os

from lib.download import downloadFile
from lib.extract import extractTar

download_dir = os.path.join(os.getcwd(), 'download')
build_dir = os.path.join(os.getcwd(), 'build')
rootfs_dir = os.path.join(os.getcwd(), 'rootfs')


def downloadSource(source):
    for package, info in source.items():
        source[package]['download']["filePath"] = downloadFile(
            info['download']["url"].replace('[VERSION]', info['version']), download_dir, True)


def extractSource(source):
    for package, info in source.items():
        source[package]['build']["buildDir"] = extractTar(
            info['download']["filePath"], build_dir, True)


def createRootFS(rootfs):
    os.mkdir(rootfs_dir)
    for dir in rootfs['dir']:
        os.mkdir(os.path.join(rootfs_dir, dir))
    for symlink in rootfs['symlink']:
        os.symlink(symlink[0], os.path.join(rootfs_dir, symlink[1]))


def startBuild(jsonInfo):
    downloadSource(jsonInfo['source'])
    extractSource(jsonInfo['source'])
    createRootFS(jsonInfo['rootfs'])


def getJSONInfo():
    with open(os.path.join(os.getcwd(), 'info.json')) as info:
        jsonInfo = json.load(info)
    return jsonInfo


jsonInfo = getJSONInfo()
startBuild(jsonInfo)
print(json.dumps(jsonInfo, indent=2))
