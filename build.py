import json
import os

from lib.download import downloadFile
from lib.extract import extractTar

download_dir = os.path.join(os.getcwd(), 'download')
build_dir = os.path.join(os.getcwd(), 'build')
rootfs_dir = os.path.join(os.getcwd(), 'rootfs')


def downloadSource(source):
    for package, info in source.items():
        source[package]["filePath"] = downloadFile(
            info["url"].replace('[VERSION]', info['version']), download_dir, True)


def extractSource(source):
    for package, info in source.items():
        source[package]["buildDir"] = extractTar(
            info["filePath"], build_dir, True)


def createRootFS(rootfs):
    os.mkdir(rootfs_dir)
    for dir in rootfs['dir']:
        os.mkdir(os.path.join(rootfs_dir, dir))
    for symlink in rootfs['symlink']:
        os.symlink(symlink[0], os.path.join(rootfs_dir, symlink[1]))


def startBuild(jsonInfo):
    source = jsonInfo['source']
    rootfs = jsonInfo['rootfs']

    downloadSource(source)
    extractSource(source)
    createRootFS(rootfs)


with open(os.path.join(os.getcwd(), 'info.json')) as info:
    jsonInfo = json.load(info)

startBuild(jsonInfo)