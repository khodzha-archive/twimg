defmodule Twimg.Helpers do
  def phashes(path) do
    { json, _ } = System.cmd("percephash", [path])
    {:ok, hashes } = Poison.decode(json)

    hashes
    |> Enum.map(fn {k, v} -> {k, :erlang.list_to_binary(v)} end)
    |> Enum.into(%{})
  end

  def extract_filename_from_url(url) do
    url
    |> URI.parse
    |> Map.get(:path)
    |> String.split("/")
    |> List.last
  end
end
