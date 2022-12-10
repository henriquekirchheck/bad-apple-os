from typing import List


def extractTar(tarFilePath: str, outPath: str, progress: bool = False):
    """
    Extracts files from tar with the tarfile python module

    Arguments:
      tarFilePath: path string where the tar file is located         | "/home/USER/Downloads/linux-VERSION.tar.xz"
      path: directory string where the extracted files will be saved | "/home/USER/Downloads/out"
      progress: boolean to show or hide progress bar                 | True
    Returns:
      The complete directory path string                             | "/home/USER/Downloads/out/linux-VERSION"
    """
    import os
    import tarfile as tar
    from pathlib import Path

    from tqdm.auto import tqdm

    def remove_tar_extention(file: str):
        suffixes = ''.join(Path(file).suffixes[-2:])
        return file.replace(suffixes, '')

    if os.path.isdir(tarFilePath):
        raise Exception("Tar File Path cannot be a Directory")
    if os.path.isfile(outPath):
        raise Exception("Output Path cannot be a File")
    if not os.path.exists(outPath):
        os.makedirs(outPath)

    filename = os.path.basename(tarFilePath)

    if progress:
        with tar.open(tarFilePath, 'r:*') as tarFile:
            for member in tqdm(iterable=tarFile.getmembers(), total=len(tarFile.getmembers()), desc=f"Extracting {filename}"):
                tarFile.extract(member, outPath)
    else:
        with tar.open(tarFilePath, 'r:*') as tarFile:
            def is_within_directory(directory, target):
                
                abs_directory = os.path.abspath(directory)
                abs_target = os.path.abspath(target)
            
                prefix = os.path.commonprefix([abs_directory, abs_target])
                
                return prefix == abs_directory
            
            def safe_extract(tar, path=".", members=None, *, numeric_owner=False):
            
                for member in tar.getmembers():
                    member_path = os.path.join(path, member.name)
                    if not is_within_directory(path, member_path):
                        raise Exception("Attempted Path Traversal in Tar File")
            
                tar.extractall(path, members, numeric_owner=numeric_owner) 
                
            
            safe_extract(tarFile, outPath)

    return os.path.join(outPath, remove_tar_extention(filename))


def extractTars(tarFilePaths: List[str], outPath: str, progress: bool = False):
    """
    Extracts files from tars with the tarfile python module

    Arguments:
      tarFilePaths: path list if strings where the tar files are located | "/home/USER/Downloads/linux-VERSION.tar.xz"
      path: directory string where the extracted files will be saved     | "/home/USER/Downloads/out"
      progress: boolean to show or hide progress bar                     | True
    Returns:
      A list with all the complete directory path string                 | "/home/USER/Downloads/out/linux-VERSION"
    """

    return [extractTar(tarFilePath, outPath, progress) for tarFilePath in tarFilePaths]


if __name__ == '__main__':
    import os
    archive_list = [
        os.path.join(os.getcwd(), 'download-test', 'linux-5.15.52.tar.xz'),
        os.path.join(os.getcwd(), 'download-test', 'glibc-2.35.tar.xz')
    ]
    help(extractTar)
    help(extractTars)
    print(extractTars(archive_list, os.path.join(
        os.getcwd(), 'extract-test'), True))
