defmodule Twimg.PictureView do
  use Twimg.Web, :view

  def render("result.json", %{picture: picture, success: success}) do
    IO.puts(inspect picture)
    %{
      success: success,
      picture: Map.take(picture, ~w(id full_url filename))
    }
  end

  def render("result.json", %{changeset: changeset, success: success}) do
    IO.inspect(changeset.errors)
    errors = Enum.map(changeset.errors, fn {field, detail} ->
      IO.puts(inspect detail)
      %{
        source: %{ pointer: "/data/attributes/#{field}" },
        title: "Invalid Attribute",
        detail: render_detail(detail)
      }
    end)

    %{
      success: success,
      errors: errors
    }
  end

  def render_detail({message, values}) when is_list(values) do
    Enum.reduce values, message, fn {k, v}, acc ->
      String.replace(acc, "%{#{k}}", to_string(v))
    end
  end

  def render_detail({message, values}) do
    Enum.reduce values, message, fn {k, v}, acc ->
      String.replace(acc, "%{#{k}}", to_string(v))
    end
  end

  def render_detail(message) do
    message
  end
end
