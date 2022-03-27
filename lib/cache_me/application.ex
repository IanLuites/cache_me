defmodule CacheMe.Application do
  @moduledoc false
  use Application

  @impl Application
  def start(_type, _args) do
    children = [CacheMe.Cache.Compile, CacheMe.Cache.ETS]

    opts = [strategy: :one_for_one, name: CacheMe.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
