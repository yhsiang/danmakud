# run this with:
# createdb danmakud
# lsc app.ls --db danmakud --schema pgrest
meta = do
  'pgrest.videos': do
    as: 'public.videos'
    primary: \id
    columns:
      '*': {}
      danmaku:
        $from: 'public.danmaku'
        $query: 'video_id': $literal: 'videos.id'
        columns:
          '*': <[id content video_id display_offset created_at created_by]>

require! pgrest
opts = {schema: 'pgrest', prefix: '/api/collections'} <<< pgrest.get-opts!! <<< {meta}

app, plx, server <- pgrest.cli! opts, <[]>, [], require \./lib

io = require 'socket.io' .listen server

io.sockets.on 'connection' (socket) ->
  console.log \conncetion
  socket.emit 'news' hello: 'world'
  socket.on 'my other event' (data) ->
    console.log data
