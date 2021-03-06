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
    for state <- [ :won, :lost ] do
      game = Game.new_game |> Map.put(:game_state, state)
      assert {^game, _} = Game.make_move(game, "x")
    end
  end

  test "first occurrence of letter is not already used" do
    game = Game.new_game |> Game.make_move("x") |> elem(0)
    assert game.game_state != :already_used
  end

  test "second occurrence of letter is not already used" do
    game =
      Game.new_game
      |> Game.make_move("x")
      |> elem(0)
      |> Game.make_move("x")
      |> elem(0)

    assert game.game_state == :already_used
  end

  test "a good guess is recognized" do
    game =
      Game.new_game("wribble")
      |> Game.make_move("w")
      |> elem(0)

    assert game.game_state == :good_guess
    assert game.turns_left == 7
  end

  test "a guessed word is a won game" do
    word = "wribble"
    game =
      word
      |> String.codepoints
      |> Enum.reduce(Game.new_game(word), fn c, game ->
        Game.make_move(game, c)
        |> elem(0)
      end)

    assert game.game_state == :won
    assert game.turns_left == 7
  end

  test "bad guess is recognized" do
    game =
      Game.new_game("wibble")
      |> Game.make_move("x")
      |> elem(0)

    assert game.game_state == :bad_guess
    assert game.turns_left == 6
  end

  test "lost game is recognized" do
    game =
      1..7
      |> Enum.reduce(Game.new_game("wribble"), fn c, game ->
        Game.make_move(game, c)
        |> elem(0)
      end)

    assert game.game_state == :lost
    assert game.turns_left == 0
  end

end
