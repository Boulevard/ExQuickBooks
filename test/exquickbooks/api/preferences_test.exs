defmodule ExQuickBooks.API.PreferencesTest do
  use ExUnit.Case, async: false
  use ExQuickBooks.APICase

  alias ExQuickBooks.API.Preferences
  alias ExQuickBooks.OAuth.AccessToken

  doctest Preferences

  @token %AccessToken{
    token: "token",
    token_secret: "secret",
    realm_id: "realm_id"
  }

  test "read_preferences/2 retrieves preferences" do
    load_response("preferences/read_preferences.json") |> send_response

    assert {:ok, %{"Preferences" => _}} =
      Preferences.read_preferences(@token)
  end

  test "update_preferences/3 updates and retrieves preferences" do
    load_response("preferences/update_preferences.json") |> send_response

    assert {:ok, %{"Preferences" => _}} =
      Preferences.update_preferences(@token, %{foo: true})

    assert %{body: body} = take_request()
    assert String.contains?(to_string(body), "foo")
  end

  test "update_preferences/3 recovers from an error" do
    load_response("preferences/update_preferences_error.json")
    |> Map.put(:status_code, 400)
    |> send_response

    assert {:error, %{"Fault" => _}} =
      Preferences.update_preferences(@token, %{foo: true})
  end
end
