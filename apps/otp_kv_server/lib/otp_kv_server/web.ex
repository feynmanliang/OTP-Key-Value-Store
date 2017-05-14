defmodule KVServer.Web do
  use Plug.Router
  require Logger

  plug Plug.Logger
  plug :match
  plug :dispatch

  def init(options), do: options

  get "/" do
    send_resp(conn, 200, "Welcome")
  end

  post "/upload" do
    send_resp(conn, 201, "Upload")
  end

  match _ do
    send_resp(conn, 404, "Not found!")
  end
end
