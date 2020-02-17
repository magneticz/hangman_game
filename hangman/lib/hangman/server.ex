defmodule Hangman.Server do
  alias Hangman.Game
  use GenServer

  def init(_) do
    {:ok, Game.new_game()}
  end

  def start_link() do
    GenServer.start_link(__MODULE__, nil)
  end

  def handle_call({:make_move, guess}, _form, game) do
    {game, tally} = Game.make_move(game, guess)

    {:reply, tally, game}
  end

  def handle_call({:tally}, _form, game) do
    {:reply, Game.tally(game), game}
  end
end
