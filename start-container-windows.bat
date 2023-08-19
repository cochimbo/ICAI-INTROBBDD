:: Create a Docker volume named ICAIDATA
docker volume create ICAIDATA

:: Create a directory for your workspace in your user profile folder
if not exist %USERPROFILE%\workspace mkdir %USERPROFILE%\workspace

:: Run a Docker container with volume and directory mounts
docker run --name practicasbbdd -v ICAIDATA:/var/lib/mysql -v %USERPROFILE%\workspace:/workspace cochimbo/introbbddicade
