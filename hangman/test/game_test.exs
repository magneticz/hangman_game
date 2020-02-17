defmodule GameTest do
  use ExUnit.Case
  alias Hangman.Game

  test "new_game returns structure" do
    game = Game.new_game()

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
  end

  test "state isn't changed for :won or :lost game" do
    for state <- [:won, :lost] do
      game = Game.new_game() |> Map.put(:game_state, state)
      {new_game, _} = Game.make_move(game, "x")
      assert new_game == game
    end
  end

  test "state is changed when letter is already used" do
    {game, _} = Game.new_game("xmen") |> Game.make_move("x")
    assert MapSet.member?(game.used, "x") == true
    assert game.game_state == :good_guess

    {game, _} = Game.make_move(game, "x")
    assert MapSet.member?(game.used, "x") == true
    assert game.game_state == :already_used
  end

  test "a good guess is recognized" do
    game = Game.new_game("wibble")
    {game, _} = Game.make_move(game, "w")

    assert game.game_state == :good_guess
    assert game.turns_left == 7
  end

  test "a bad guess is recognized" do
    game = Game.new_game("wibble")
    {game, _} = Game.make_move(game, "x")

    assert game.game_state == :bad_guess
    assert game.turns_left == 6
  end

  test "a win is recognized" do
    moves = [
      {"w", :good_guess, 7, ["w", "_", "_", "_", "_", "_"]},
      {"i", :good_guess, 7, ["w", "i", "_", "_", "_", "_"]},
      {"b", :good_guess, 7, ["w", "i", "b", "b", "_", "_"]},
      {"b", :already_used, 7, ["w", "i", "b", "b", "_", "_"]},
      {"l", :good_guess, 7, ["w", "i", "b", "b", "l", "_"]},
      {"e", :won, 7, ["w", "i", "b", "b", "l", "e"]}
    ]

    assert_game_moves("wibble", moves)
  end

  test "a lose is recognized" do
    moves = [
      {"a", :bad_guess, 6, ["_", "_", "_", "_", "_", "_"]},
      {"b", :good_guess, 6, ["_", "_", "b", "b", "_", "_"]},
      {"c", :bad_guess, 5, ["_", "_", "b", "b", "_", "_"]},
      {"d", :bad_guess, 4, ["_", "_", "b", "b", "_", "_"]},
      {"e", :good_guess, 4, ["_", "_", "b", "b", "_", "e"]},
      {"f", :bad_guess, 3, ["_", "_", "b", "b", "_", "e"]},
      {"g", :bad_guess, 2, ["_", "_", "b", "b", "_", "e"]},
      {"h", :bad_guess, 1, ["_", "_", "b", "b", "_", "e"]},
      {"i", :good_guess, 1, ["_", "i", "b", "b", "_", "e"]},
      {"j", :lost, 0, ["_", "i", "b", "b", "_", "e"]}
    ]

    assert_game_moves("wibble", moves)
  end

  def assert_game_moves(word, moves) do
    fun = fn {guess, state, turns_left, letters}, game ->
      {game, _} = Game.make_move(game, guess)
      tally = Game.tally(game)
      assert game.game_state == state
      assert game.turns_left == turns_left

      assert tally.game_state == state
      assert tally.turns_left == turns_left
      assert tally.letters == letters
      game
    end

    Enum.reduce(moves, Game.new_game(word), fun)
  end
end
