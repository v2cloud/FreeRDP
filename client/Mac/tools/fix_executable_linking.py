import subprocess
import os
import sys
from shutil import copyfile

def file_in_folder(file, folder):
    return os.path.exists(os.path.join(folder, file))

executable = os.path.abspath(sys.argv[1])
executable_name = os.path.split(executable)[-1]
print 'executable:', executable
print 'executable_name:', executable_name

libraries_path =  os.path.join(os.path.dirname(executable), 'Resources', 'Libraries')
print 'libraries_path:', libraries_path


print ' '.join(['install_name_tool', '-id', os.path.join("@executable_path", executable_name), executable])
_ = subprocess.Popen(['install_name_tool', '-id', os.path.join("@executable_path", executable_name), executable], stdout=subprocess.PIPE)
print ' '.join(['install_name_tool', '-add_rpath', os.path.join("@executable_path", 'Resources', 'Libraries'), executable])
_ = subprocess.Popen(['install_name_tool', '-add_rpath', os.path.join("@executable_path", 'Resources', 'Libraries'), executable], stdout=subprocess.PIPE)

o = subprocess.Popen(['/usr/bin/otool', '-L', executable], stdout=subprocess.PIPE)
for l in o.stdout:
    l = l.decode()
    
    if l[0] == '\t':
        dependency_path = l.split(' ', 1)[0][1:]
        dependency_dylib_name = os.path.split(dependency_path)[-1]
        if file_in_folder(dependency_dylib_name, libraries_path):
            print ' '.join(['install_name_tool', '-change', dependency_path, os.path.join("@rpath", dependency_dylib_name), executable])
            _ = subprocess.Popen(['install_name_tool', '-change', dependency_path, os.path.join("@rpath", dependency_dylib_name), executable], stdout=subprocess.PIPE)
