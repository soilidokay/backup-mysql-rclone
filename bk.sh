#!/bin/bash

# Thông tin kết nối MySQL
HOST_MYSQL=${HOST_MYSQL}
PORT_MYSQL=${PORT_MYSQL}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
DB_NAME=${DB_NAME}
BACKUP_DIR=${BACKUP_DIR:-/backup}
DATE=$(date +"%Y%m%d%H%M")
BACKUP_FILE="$BACKUP_DIR/$DB_NAME-$DATE.sql"
RETENTION_DAYS=${RETENTION_DAYS:-7}  # Số ngày giữ lại các bản sao lưu

# Thư mục trên Google Drive (đã cấu hình với rclone)
GDRIVE_REMOTE=${GDRIVE_REMOTE}

# Tạo thư mục sao lưu nếu chưa tồn tại
mkdir -p $BACKUP_DIR

# Tạo bản sao lưu MySQL
mysqldump  -h $HOST_MYSQL -P $PORT_MYSQL -u $DB_USER -p$DB_PASSWORD $DB_NAME | gzip > $BACKUP_FILE

# bin/rclone config

# Kiểm tra xem quá trình sao lưu có thành công không
if [ $? -eq 0 ]; then
    echo "MySQL backup successful, starting upload to Google Drive."
    # Tải bản sao lưu lên Google Drive
    rclone copy $BACKUP_FILE $GDRIVE_REMOTE
    if [ $? -eq 0 ]; then
        echo "Backup uploaded to Google Drive successfully."
        # Xóa bản sao lưu cục bộ sau khi tải lên thành công
        rm -f $BACKUP_FILE
        
        # Xóa các file backup cũ trên Google Drive
        echo "Deleting old backups from Google Drive."
        rclone delete --min-age ${RETENTION_DAYS}d $GDRIVE_REMOTE
        if [ $? -eq 0 ]; then
            echo "Old backups deleted successfully."
        else
            echo "Failed to delete old backups from Google Drive."
        fi
    else
        echo "Failed to upload backup to Google Drive."
    fi
else
    echo "Failed to create MySQL backup."
fi
