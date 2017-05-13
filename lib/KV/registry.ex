defmodule KV.Registry do
  use GenServer

  ## Client API

  @doc "Starts the registry mapping string names to buckets."
  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc "Ensures there is a bucket associated to the given `name` in `server`."
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  @doc "Stops the registry."
  def stop(server) do
    GenServer.stop(server)
  end

  ## Server callbacks

  def init(:ok) do
    {:ok, Map.new}
  end

  def handle_call({:lookup, name}, _from, names) do
    {:reply, Map.fetch(names, name), names}
  end

  def handle_cast({:create, name}, names) do
    if Map.has_key?(names, name) do
      {:noreply, names}
    else
      {:ok, bucket} = KV.Bucket.start_link
      {:noreply, Map.put(names, name, bucket)}
    end
  end
end