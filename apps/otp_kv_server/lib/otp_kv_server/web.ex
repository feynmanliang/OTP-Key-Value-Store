defmodule KVServer.Web do
  use Plug.Router
  require Logger

  plug Plug.Logger
  plug Plug.Parsers, parsers: [:urlencoded]
  plug :match
  plug :dispatch

  def init(options), do: options

  get "/" do
    send_resp(conn, 200, "Welcome")
  end

  post "/buckets/create" do
    %{"bucket" => bucket} = conn.body_params
    KV.Registry.create(KV.Registry, bucket)
    send_resp(conn, 200, "Created bucket #{bucket}")
  end

  put "/buckets/:bucket/:key" do
    %{"bucket" => bucket, "key" => key} = conn.params
    %{"value" => value } = conn.body_params
    lookup bucket, conn, fn pid ->
      KV.Bucket.put(pid, key, value)
      send_resp(conn, 200, "Put #{key}=#{value} in #{bucket}")
    end
  end

  get "/buckets/:bucket/:key" do
    lookup bucket, conn, fn pid ->
      value = KV.Bucket.get(pid, key)
      unless value == nil do
        send_resp(conn, 200, "#{value}")
      else
        send_resp(conn, 500, "")
      end
    end
  end

  delete "/buckets/:bucket/:key" do
    lookup bucket, conn, fn pid ->
      KV.Bucket.delete(pid, key)
      send_resp(conn, 200, "")
    end
  end

  match _ do
    send_resp(conn, 404, "Not found!")
  end

  defp lookup(bucket, conn, callback) do
    case KV.Registry.lookup(KV.Registry, bucket) do
      {:ok, pid} -> callback.(pid)
      :error -> send_resp(conn, 500, "Bucket not found!")
    end
  end
end
