defmodule ExQuickBooks.API.AccountTest do
  use ExUnit.Case, async: false
  use ExQuickBooks.APICase

  alias ExQuickBooks.API.Account
  alias ExQuickBooks.OAuth.Credentials

  doctest Account

  @creds %Credentials{
    realm_id: "realm_id",
    token: "token"
  }

  test "read_account/3 retrieves an account" do
    load_response("account/read_account.json") |> send_response

    assert {:ok, %{"Account" => _}} = Account.read_account(@creds, "account_id")

    assert %{url: url} = take_request()
    assert String.contains?(url, "/account_id")
  end

  test "read_account/3 recovers from an error" do
    load_response("account/read_account_error.json")
    |> Map.put(:status_code, 400)
    |> send_response

    assert {:error, %{"Fault" => _}} = Account.read_account(@creds, "account_id")
  end
end
