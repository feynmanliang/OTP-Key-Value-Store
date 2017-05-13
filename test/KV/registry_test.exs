defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    {:ok, _} = KV.Registry.start_link(context.test)
    {:ok, registry: context.test}
  end

  test "spawns buckets", %{registry: registry} do
    assert KV.Registry.lookup(registry, "groceries") == :error

    KV.Registry.create(registry, "groceries")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "groceries")
  end

  test "removes entry when a bucket exits", %{registry: registry} do
    KV.Registry.create(registry, "groceries")
    {:ok, bucket} = KV.Registry.lookup(registry, "groceries")

    Agent.stop(bucket)

    assert KV.Registry.lookup(registry, "groceries") == :error
  end

  test "removes entry when a bucket crashes", %{registry: registry} do
    KV.Registry.create(registry, "groceries")
    {:ok, bucket} = KV.Registry.lookup(registry, "groceries")

    ref = Process.monitor(bucket)
    Process.exit(bucket, :shutdown) # non-normal shutdown

    # wait until bucket is dead, because (unlike Agent.stop) Process.exit is async
    assert_receive {:DOWN, ^ref, _, _, _}

    assert KV.Registry.lookup(registry, "groceries") == :error
  end
end
