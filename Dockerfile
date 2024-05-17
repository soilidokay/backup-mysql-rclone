# Sử dụng hình ảnh Ubuntu làm cơ sở
FROM ubuntu:22.04

# Cài đặt các công cụ cần thiết
RUN apt-get update && apt-get install -y \
    mysql-client \
    rclone \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*



# Thêm file cấu hình rclone vào container
COPY rclone.conf /root/.config/rclone/rclone.conf
COPY rclone-65226a1107df.json /keystore/rclone-65226a1107df.json
WORKDIR /backup
WORKDIR /app

# Thêm script sao lưu vào container
COPY bk.sh bk.sh
RUN chmod +x bk.sh

CMD [ "./bk.sh" ]

