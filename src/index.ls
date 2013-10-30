{pgrest_param_get, pgrest_param_set} = require \pgrest

export function bootstrap(plx, cb)
  # XXX: make plv8x /sql define-schema reusable
  <- plx.query """
  DO $$
  BEGIN
      IF NOT EXISTS(
          SELECT schema_name
            FROM information_schema.schemata
            WHERE schema_name = 'pgrest'
        )
      THEN
        EXECUTE 'CREATE SCHEMA pgrest';
      END IF;
  END
  $$;

  CREATE TABLE IF NOT EXISTS videos (
    id SERIAL,
    length int,
    CONSTRAINT "videos_pkey" PRIMARY KEY (id)
  );

  CREATE TABLE IF NOT EXISTS danmaku (
    id SERIAL,
    content varchar(140),
    video_id int,
    display_offset int,
    created_at timestamp,
    created_by int,
    CONSTRAINT "danmaku_pkey" PRIMARY KEY (video_id, id, display_offset)
  );
  """
  require! pgrest
  <- pgrest.bootstrap plx, \danmakud require.resolve \../package.json
  cb!

