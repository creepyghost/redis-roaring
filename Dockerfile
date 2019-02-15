FROM redis

ADD libredis-roaring.deb /
ADD http://download.redis.io/redis-stable/redis.conf /usr/local/etc/redis/redis.conf
RUN dpkg -i /libredis-roaring.deb;\
    sed -i '1i loadmodule /usr/lib/libredis-roaring.so' /usr/local/etc/redis/redis.conf; \
    chmod 644 /usr/local/etc/redis/redis.conf; \
    sed -i 's/^bind 127.0.0.1/#bind 127.0.0.1/g' /usr/local/etc/redis/redis.conf; \
    sed -i 's/^protected-mode yes/protected-mode no/g' /usr/local/etc/redis/redis.conf
CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]
