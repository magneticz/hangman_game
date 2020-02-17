defmodule Hangman.Application do
  use Application

  def start(_typw, _args) do
    import Supervisor.Spec

    children = [
      worker(Hangman.Server, [])
    ]

    options = [
      name: Hangmans.Supervisor,
      strategy: :simple_one_for_one
    ]

    Supervisor.start_link(children, options)
  end
end
