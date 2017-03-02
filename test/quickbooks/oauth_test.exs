defmodule QuickBooks.OAuthTest do
  use ExUnit.Case, async: false
  use QuickBooks.APICase

  alias QuickBooks.OAuth

  doctest OAuth

  test "get_request_token/0 returns token and callback url" do
    load_response("oauth/get_request_token") |> send_response

    assert OAuth.get_request_token ==
      {:ok, %{
        "oauth_token" => "token",
        "oauth_token_secret" => "secret",
        "oauth_callback_confirmed" => "true"
      }, "https://appcenter.intuit.com/Connect/Begin?oauth_token=token"}
  end
end
