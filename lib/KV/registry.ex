defmodule KV.Registry do
  use GenServer

  ## Client API

  @doc "Starts the registry mapping string names to buckets."
  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
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
    GenServer.call(server, {:create, name})
  end

  @doc "Stops the registry."
  def stop(server) do
    GenServer.stop(server)
  end

  ## Server callbacks

  def init(:ok) do
    names = Map.new # name -> bucket pid, to resolve buckets by name
    refs = Map.new # ref -> name, to handle Monitor messages
    {:ok, {names, refs}}
  end

  def handle_call({:lookup, name}, _from, {names, _} = state) do
    {:reply, Map.fetch(names, name), state}
  end

  def handle_call({:create, name}, _from, {names, refs}) do
    if Map.has_key?(names, name) do
      {:reply, :ok, {names, refs}}
    else
      {:ok, bucket} = KV.Bucket.start_link
      ref = Process.monitor(bucket)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, bucket)
      {:reply, :ok, {names, refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
