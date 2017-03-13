defmodule ExQuickBooks.PreferencesTest do
  use ExUnit.Case, async: false
  use ExQuickBooks.APICase

  alias ExQuickBooks.Preferences
  alias ExQuickBooks.Token

  doctest Preferences

  @token %Token{
    token: "token",
    token_secret: "secret"
  }

  @realm_id "realm_id"

  test "read_preferences/2 retrieves preferences" do
    load_response("preferences/read_preferences.json") |> send_response

    assert {:ok, %{"Preferences" => _}} =
      Preferences.read_preferences(@token, @realm_id)

    assert %{url: url} = take_request()
    assert String.contains?(url, "/realm_id/")
  end

  test "update_preferences/3 updates and retrieves preferences" do
    load_response("preferences/update_preferences.json") |> send_response

    assert {:ok, %{"Preferences" => _}} =
      Preferences.update_preferences(@token, @realm_id, %{"foo" => true})

    assert %{url: url, body: body} = take_request()
    assert String.contains?(url, "/realm_id/")
    assert String.contains?(to_string(body), "foo")
  end

  test "update_preferences/3 recovers from an error" do
    load_response("preferences/update_preferences_error.json")
    |> Map.put(:status_code, 400)
    |> send_response

    assert {:error, %{"Fault" => _}} =
      Preferences.update_preferences(@token, @realm_id, %{"foo" => true})
  end
end
