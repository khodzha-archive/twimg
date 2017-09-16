defmodule Twimg.PageController do
  use Twimg.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
