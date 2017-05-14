defmodule KV.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(KV.Registry, [KV.Registry]),
      supervisor(KV.Bucket.Supervisor, []),
      supervisor(Task.Supervisor, [[name: KV.RouterTasks]])
    ]

    # since bucket supervisors started after registry,
    # `rest_for_one` will allow registry to clean up after bucket supervisor failure
    # but will restart all bucket supervisors when registry fails, preventing orphaning
    # (dead registry => impossible to look up pid for a bucket name)
    supervise(children, strategy: :rest_for_one)
  end
end
