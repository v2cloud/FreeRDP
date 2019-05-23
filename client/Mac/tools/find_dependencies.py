import subprocess
import os
import sys
from shutil import copyfile

executable = sys.argv[1]

app_folder = os.path.join(*executable.split('/')[:-3])
content_folder = os.path.join(app_folder, "Contents")
framework_path = os.path.join(content_folder, "Frameworks")

def file_in_folder(file, folder):
    return os.path.exists(os.path.join(folder, file))

def otool(s):
    o = subprocess.Popen(['/usr/bin/otool', '-L', s], stdout=subprocess.PIPE)
    
    for l in o.stdout:
        l = l.decode()
        
        if l[0] == '\t':
            path = l.split(' ', 1)[0][1:]
            
            if "@executable_path" in path:
                path = path.replace("@executable_path", "")
                path = os.path.join(content_folder, path[4:])
            
            if "@loader_path" in path:
                path = path.replace("@loader_path", framework_path)
            
            if "@rpath" in path:
                path = path.replace("@rpath", framework_path)
            
            if '/local/lib' in path:
                yield path

need = set([executable])
done = set()

while need:
    needed = set(need)
    need = set()
    for f in needed:
        need.update(otool(f))
    done.update(needed)
    need.difference_update(done)

for p in sorted(done):
    if p != executable:
         print p


