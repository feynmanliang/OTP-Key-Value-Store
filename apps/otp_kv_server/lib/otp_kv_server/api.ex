defmodule KVServer.Api do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    port = Application.get_env(:otp_kv_server, :cowboy_port, 8080)

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: KVServer.Worker.start_link(arg1, arg2, arg3)
      Plug.Adapters.Cowboy.child_spec(:http, KVServer.Web, [], port: port)
    ]

    Logger.info "Application listening on port #{port}"

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KVServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
