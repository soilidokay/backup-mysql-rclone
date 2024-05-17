rclone rcd --rc-web-gui

docker image rm nttkimsong/backup-mysql:latest
docker build -t nttkimsong/backup-mysql:latest .
docker push nttkimsong/backup-mysql:latest 

git init
git add .
git push