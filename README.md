# tail-bridge

tail -f to Redis bridge. Goes best with [twitter-stream-collector](https://github.com/darashi/twitter-stream-collector).

## Usage:

    DB_PATH="[/data/twitter/]YYYY/MM/[twitter].YYYYMMDD.HH[.jsons]" REDIS_CHANNEL=twitter npm start

`DB_PATH` specifies the filename format of destination files. `DB_PATH` is treated as [Moment.js](http://momentjs.com/) format string (in UTC).

`REDIS_HOST`, `REDIS_PORT` and `REDIS_PASSWORD` are optional. If none specified, it connects localhost:6379 without password.
