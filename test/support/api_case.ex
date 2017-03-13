defmodule ExQuickBooks.APICase do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  alias ExQuickBooks.MockBackend
  alias HTTPoison.Response

  def http_200_response do
    %Response{
      body: "",
      headers: [],
      status_code: 200
    }
  end

  def http_400_response do
    %Response{
      body: "400 Bad Request",
      headers: [],
      status_code: 400
    }
  end

  def load_response(file) do
    body =
      "test/fixtures/#{file}"
      |> File.read!
      |> String.strip

    content_type =
      file
      |> String.split(".")
      |> List.last
      |> type_for_extension

    %Response{
      body: body,
      headers: [{"Content-Type", content_type}],
      status_code: 200
    }
  end

  defdelegate take_request, to: MockBackend
  defdelegate send_response(response), to: MockBackend

  defp type_for_extension("json"),  do: "application/json"
  defp type_for_extension(_),       do: "text/plain"
end
