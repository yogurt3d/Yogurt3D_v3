# Build
- Download & Install Python 2.6 (http://www.python.org/download/releases/2.6/)
- Add Python directory to PATH
- Download FBX SDK Python from Autodesk
- Copy the contents of <yourFBXSDKpath>\lib\<Pythonxxxxxx>\ into:
    Windows: yourPythonPath\Lib\site-packages\
    Mac OSX: /Library/Python/x.x/site-packages/
    Linux: /usr/local/lib/pythonx.x/site-packages/
- run "python dependencies/ez_setup.py" to install easy_install
- find easy_install in your Pythonx.x/Scripts directory
- Run "easy_install --always-unzip pylzma"
- Run "easy_install --always-unzip psd_tools"
- Run "easy_install --always-unzip wx"
- Run "easy_install --always-unzip PIL"
- Run "easy_install --always-unzip Pillow"

# Run
## Run Using Python 
python main.py fbxfile.fbx
## Create exe
- Run "easy_install --always-unzip py2exe"
- Run "python setup.py py2exe"
