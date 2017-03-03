defmodule ExQuickBooks.OAuthTest do
  use ExUnit.Case, async: false
  use ExQuickBooks.APICase

  alias ExQuickBooks.OAuth

  doctest OAuth

  test "get_request_token/0 returns token and callback url" do
    load_response("oauth/get_request_token") |> send_response

    assert OAuth.get_request_token ==
      {:ok,
        %{"oauth_token" => "token",
          "oauth_token_secret" => "secret",
          "oauth_callback_confirmed" => "true"},
        "https://appcenter.intuit.com/Connect/Begin?oauth_token=token"}
  end

  test "get_request_token/0 recovers when there's an OAuth problem" do
    load_response("oauth/get_request_token_problem") |> send_response

    assert OAuth.get_request_token ==
      {:error,
        %{"oauth_problem" => "signature_invalid"}}
  end

  test "get_request_token/0 recovers when there's some other error" do
    http_400_response() |> send_response
    assert {:error, _} = OAuth.get_request_token
  end
end
