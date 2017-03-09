defmodule ExQuickBooks.OAuthTest do
  use ExUnit.Case, async: false
  use ExQuickBooks.APICase

  alias ExQuickBooks.OAuth
  alias ExQuickBooks.Token

  doctest OAuth

  test "get_request_token/0 returns token and callback url" do
    load_response("oauth/get_request_token") |> send_response

    assert OAuth.get_request_token ==
      {:ok,
       %Token{token: "token", token_secret: "secret"},
       "https://appcenter.intuit.com/Connect/Begin?oauth_token=token"}
  end

  test "get_request_token/0 recovers when there's an OAuth problem" do
    load_response("oauth/get_request_token_problem") |> send_response

    assert OAuth.get_request_token ==
      {:error, %{"oauth_problem" => "signature_invalid"}}
  end

  test "get_request_token/0 recovers when there's some other error" do
    http_400_response() |> send_response
    assert {:error, _} = OAuth.get_request_token
  end

  test "get_access_token/2 returns token" do
    token = %Token{token: "token", token_secret: "secret"}

    load_response("oauth/get_access_token") |> send_response

    assert OAuth.get_access_token(token, "verifier") == {:ok, token}
  end

  test "get_access_token/2 recovers when there's an OAuth problem" do
    token = %Token{token: "token", token_secret: "secret"}

    load_response("oauth/get_access_token_problem") |> send_response

    assert OAuth.get_access_token(token, "verifier") ==
      {:error, %{"oauth_problem" => "signature_invalid"}}
  end

  test "get_access_token/2 recovers when there's some other error" do
    token = %Token{token: "token", token_secret: "secret"}

    http_400_response() |> send_response

    assert {:error, _} = OAuth.get_access_token(token, "verifier")
  end
end
