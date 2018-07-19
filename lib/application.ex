defmodule ExBanking.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: true
  
    children = [
      supervisor(ExBanking.User.Supervisor, []),
      supervisor(Eternal, [
        ExBanking.User.Wallet,
        [:set, {:read_concurrency, true}, {:write_concurrency, true}]
      ]),
      {Registry, keys: :unique, name: Registry.User}
    ]

    opts = [strategy: :one_for_one, name: ExBanking.Application]
    Supervisor.start_link(children, opts)
  end
end
