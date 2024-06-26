defmodule POP.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      POPWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:pop, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: POP.PubSub},
      # Start a worker by calling: POP.Worker.start_link(arg)
      # {POP.Worker, arg},
      # Start to serve requests, typically the last entry
      POPWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: POP.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    POPWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
