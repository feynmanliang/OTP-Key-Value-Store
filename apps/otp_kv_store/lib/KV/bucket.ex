defmodule KV.Bucket do
  @doc """
  Starts a new bucket.
  A `bucket` is an `agent` holding a key-value `map`.
  """
  def start_link do
    Agent.start_link(fn -> Map.new end)
  end

  @doc "Gets a value from the `bucket` by `key`."
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc "Puts the `value` for the given `key` in the `bucket`."
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  @doc """
  Deletes `key` from `bucket`.

  Returns the value of `key` before deletion, if `key` exists.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end
end
