defmodule ExQuickBooks.Backend.Mock do
  @moduledoc false
  @behaviour ExQuickBooks.Backend

  alias ExQuickBooks.Request
  alias HTTPoison.Response

  @default_response %Response{
    body: "",
    headers: [],
    status_code: 200
  }

  def request(request = %Request{}) do
    send_request(request)
    {:ok, take_response()}
  end

  def take_request(timeout \\ 0) do
    receive do
      {__MODULE__, request = %Request{}} -> request
    after
      timeout -> nil
    end
  end

  def send_response(response = %Response{}) do
    send self(), {__MODULE__, response}
  end

  defp take_response(timeout \\ 0) do
    receive do
      {__MODULE__, response = %Response{}} -> response
    after
      timeout -> @default_response
    end
  end

  defp send_request(request = %Request{}) do
    send self(), {__MODULE__, request}
  end
end
