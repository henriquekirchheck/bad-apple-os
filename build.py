import json
import os
import shutil
import subprocess

from lib.download import downloadFile
from lib.extract import extractTar

download_dir = os.path.join(os.getcwd(), 'download')
build_dir = os.path.join(os.getcwd(), 'build')
rootfs_dir = os.path.join(os.getcwd(), 'rootfs')
src_dir = os.path.join(os.getcwd(), 'src')


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


def buildSource(source):
    for package, info in source.items():
        print(f"Building {package.upper()}")
        for copyOperation in info["build"].get("copy", []):
            src_file = copyOperation[0].replace("[ROOTFS]", rootfs_dir).replace(
                "[SRC]", src_dir).replace("[BUILD_DIR]", info["build"]["buildDir"])
            dest_file = copyOperation[1].replace("[ROOTFS]", rootfs_dir).replace(
                "[SRC]", src_dir).replace("[BUILD_DIR]", info["build"]["buildDir"])
            shutil.copyfile(src_file, dest_file)
        for buildStep in info["build"].get("step", []):
            space = " "
            print(f"{package.upper()}: {space.join(buildStep)}")
            process = subprocess.Popen([arg.replace("[ROOTFS]", rootfs_dir) for arg in buildStep],
                                       stdout=subprocess.PIPE,
                                       universal_newlines=True,
                                       cwd=info["build"]["buildDir"])

            while True:
                output = process.stdout.readline()
                if output.strip():
                    print(f"{package.upper()}: {output.strip()}")
                return_code = process.poll()
                if return_code is not None:
                    print(f"{package.upper()}: Return Code {return_code}\n")
                    break


def startBuild(jsonInfo):
    downloadSource(jsonInfo['source'])
    extractSource(jsonInfo['source'])
    createRootFS(jsonInfo['rootfs'])
    buildSource(jsonInfo['source'])


def getJSONInfo():
    with open(os.path.join(os.getcwd(), 'info.json')) as info:
        jsonInfo = json.load(info)
    return jsonInfo


jsonInfo = getJSONInfo()
startBuild(jsonInfo)
