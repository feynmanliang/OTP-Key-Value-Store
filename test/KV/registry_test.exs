defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, registry} = KV.Registry.start_link
    {:ok, registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    assert KV.Registry.lookup(registry, "groceries") == :error

    KV.Registry.create(registry, "groceries")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "groceries")
  end
end
