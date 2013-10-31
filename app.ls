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
  # subscribe video
  # XXX pqg enqueue
  socket.on 'subscribe' (video) ->
    q = [{collection: "danmaku", q:{video_id: video.id}}]
    rows <- plx.query "select pgrest_select($1)", q
    socket.emit 'danmaku', rows[0].pgrest_select.entries

  # insert danmaku
  # XXX pgq notify -> check subscribed collections/queues -> socket dispatch  
  socket.on 'insert' (danmaku) ->
    if danmaku.video_id === null
      danmaku.created_at = new Date!
      q = [{collection: "danmaku", $: [danmaku]}]
      plx.query "select pgrest_insert($1)", q, (res) ->
        console.log res
    else
      socket.emit 'error', msg: 'insert failed'

