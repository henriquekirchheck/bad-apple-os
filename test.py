import os
import tarfile as tar

build_folder = os.path.join(os.getcwd(), 'build')

arquives = [
    {
        'path': '/home/henrique/git/projects/bad-apple-os/download/linux-5.15.52.tar.xz',
        'filename': 'linux-5.15.52.tar.xz'
    }
]


for
with tar.open() as tarFile:
    tarFile.extractall(build_folder)
