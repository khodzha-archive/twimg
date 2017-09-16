defmodule Twimg.PictureCreator do
  alias Twimg.Helpers
  alias Twimg.Picture
  alias Twimg.Repo

  def create(filename, upload, full_url \\ "") do
    filename = Regex.replace(~r/:large$/, filename, "")

    possible_source =
      cond do
          Regex.match?(~r/(danbooru)|(drawn_by)/, full_url) -> "danbooru"
          Regex.match?(~r/:large$/, full_url) -> "twitter"
          Regex.match?(~r/twimg/, full_url) -> "twitter"
          true -> ""
      end

    %{"md5" => md5, "dct" => dct, "gradient" => gradient, "mean" => mean} = Helpers.phashes(upload.path)

    changeset = Picture.changeset(%Picture{}, %{
      :full_url => full_url,
      :md5 => md5,
      :filename => filename,
      :possible_source => possible_source,
      :dct => dct,
      :gradient => gradient,
      :mean => mean
    })

    case Repo.insert(changeset) do
      {:ok, picture} ->
        File.cp!(upload.path, "twimg_pics/#{filename}")
        {:ok, picture}
      {:error, changeset} -> {:error, changeset}
    end
  end
end
