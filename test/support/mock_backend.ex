defmodule QuickBooks.MockBackend do
  @moduledoc false
  @behaviour QuickBooks.Backend

  alias QuickBooks.MockRequest
  alias QuickBooks.MockResponse

  @default_response %MockResponse{
    body: "",
    headers: [],
    status_code: 200
  }

  def request(method, url, body, headers, options) do
    %MockRequest{
      method: method,
      url: url,
      body: body,
      headers: headers,
      options: options
    } |> send_request()

    {:ok, take_response() |> convert_mock_response()}
  end

  def take_request(timeout \\ 0) do
    receive do
      request = %MockRequest{} -> request
    after
      timeout -> nil
    end
  end

  def send_response(response = %MockResponse{}) do
    send self(), response
  end

  defp take_response(timeout \\ 0) do
    receive do
      response = %MockResponse{} -> response
    after
      timeout -> @default_response
    end
  end

  defp send_request(request = %MockRequest{}) do
    send self(), request
  end

  defp convert_mock_response(response = %MockResponse{}) do
    struct!(HTTPoison.Response, response |> Map.from_struct)
  end
end
