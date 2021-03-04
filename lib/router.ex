defmodule SocketV1.Router do

  use Plug.Router
  require EEx

  plug Plug.Static, at: "/", from: :socket_v1
  plug :match
  plug :dispatch
  plug Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder:  {Jason, :decode!, [[keys: :atoms]]}

  EEx.function_from_file(:defp, :app_init, "lib/template/app.html.eex", [])

  get "/" do
    send_resp(conn, 200, app_init())
  end

  match _ do
    send_resp(conn, 404 , "404")
  end

end
