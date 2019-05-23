import subprocess
import os
import sys, glob
from shutil import copyfile

def file_in_folder(file, folder):
    return os.path.exists(os.path.join(folder, file))


libraries_path = sys.argv[1]
libs = [f for f in glob.glob(libraries_path + "/*.dylib")]

for lib in libs:
    o = subprocess.Popen(['/usr/bin/otool', '-L', lib], stdout=subprocess.PIPE)

    for l in o.stdout:
        l = l.decode()

        if l[0] == '\t':
            dependency_path = l.split(' ', 1)[0][1:]

            dependency_dylib_name = os.path.split(dependency_path)[-1]
            if file_in_folder(dependency_dylib_name, libraries_path):
                if dependency_dylib_name == os.path.split(lib)[-1]:
                    print ' '.join(['install_name_tool', '-id', os.path.join("@loader_path", dependency_dylib_name), lib])
                    _ = subprocess.Popen(['install_name_tool', '-id', os.path.join("@loader_path", dependency_dylib_name), lib], stdout=subprocess.PIPE)
                print ' '.join(['install_name_tool', '-change', dependency_path, os.path.join("@loader_path", dependency_dylib_name), lib])
                _ = subprocess.Popen(['install_name_tool', '-change', dependency_path, os.path.join("@loader_path", dependency_dylib_name), lib], stdout=subprocess.PIPE)


