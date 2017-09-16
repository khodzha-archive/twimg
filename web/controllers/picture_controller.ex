defmodule Twimg.PictureController do
  use Twimg.Web, :controller

  alias Twimg.Picture
  alias Twimg.Helpers
  alias Twimg.PictureCreator

  def index(conn, _params) do
    pictures = Repo.all(Picture)
    render(conn, "index.html", pictures: pictures)
  end

  def new(conn, _params) do
    changeset = Picture.changeset(%Picture{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"picture" => picture_params}) do
    changeset = Picture.changeset(%Picture{}, picture_params)

    case Repo.insert(changeset) do
      {:ok, _picture} ->
        conn
        |> put_flash(:info, "Picture created successfully.")
        |> redirect(to: picture_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def create_multiple(conn, %{"format" => "json", "picture" => picture_params}) do
    if full_url = picture_params["full_url"] do
      upload = picture_params["file"]
      filename = if upload do
        upload.filename
      else
        Helpers.extract_filename_from_url(full_url)
      end

      upload =
        case upload do
          nil ->
            {:ok, tmp_path} = Briefly.create
            %HTTPoison.Response{body: body} = HTTPoison.get!(full_url)
            File.write!(tmp_path, body)
            %{content: body, path: tmp_path, filename: Path.basename(tmp_path)}

          _ -> upload
        end

      case PictureCreator.create(filename, upload, full_url) do
        {:ok, picture} ->
          render(conn, "result.json", picture: picture, success: true)
        {:error, changeset} ->
          render(conn, "result.json", changeset: changeset, success: false)
      end

    end
  end

  def show(conn, %{"id" => id}) do
    picture = Repo.get!(Picture, id)
    render(conn, "show.html", picture: picture)
  end

  def edit(conn, %{"id" => id}) do
    picture = Repo.get!(Picture, id)
    changeset = Picture.changeset(picture)
    render(conn, "edit.html", picture: picture, changeset: changeset)
  end

  def update(conn, %{"id" => id, "picture" => picture_params}) do
    picture = Repo.get!(Picture, id)
    changeset = Picture.changeset(picture, picture_params)

    case Repo.update(changeset) do
      {:ok, picture} ->
        conn
        |> put_flash(:info, "Picture updated successfully.")
        |> redirect(to: picture_path(conn, :show, picture))
      {:error, changeset} ->
        render(conn, "edit.html", picture: picture, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    picture = Repo.get!(Picture, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(picture)

    conn
    |> put_flash(:info, "Picture deleted successfully.")
    |> redirect(to: picture_path(conn, :index))
  end
end
