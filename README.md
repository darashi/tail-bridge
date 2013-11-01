# tail-bridge

tail -f to AMQP bridge. Goes best with [twitter-stream-collector](https://github.com/darashi/twitter-stream-collector).

## Usage:

    DB_PATH="[/data/twitter/]YYYY/MM/[twitter].YYYYMMDD.HH[.jsons]" AMQP_URL=amqp://user:pass@127.0.0.1 AMQP_EXCHANGE_NAME=twitter npm start

`DB_PATH` specifies the filename format of destination files. `DB_PATH` is treated as [Moment.js](http://momentjs.com/) format string (in UTC).
