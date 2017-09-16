defmodule Twimg.Picture do
  use Twimg.Web, :model
  import Ecto.Query
  alias Twimg.Repo
  alias Twimg.Picture

  schema "pictures" do
    field :full_url,        :string
    field :filename,        :string
    field :md5,             :binary
    field :possible_source, :string
    field :mean,            :binary
    field :gradient,        :binary
    field :dct,             :binary

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:full_url, :filename, :md5, :possible_source, :gradient, :mean, :dct])
    |> validate_required([:filename, :md5, :gradient, :mean, :dct])
    |> unique_constraint(:md5)
    |> unique_constraint(:mean)
    |> unique_constraint(:gradient)
    |> unique_constraint(:dct)
    |> unique_constraint(:full_url)
    |> unique_constraint(:filename)
    |> validate_similar_pictures([:gradient, :dct])
  end

  defmacro hamming(p, field, value) do
    quote do
      fragment("hamming(?, ?)", field(unquote(p), ^unquote(field)), ^unquote(value))
    end
  end

  def validate_similar_pictures(changeset, fields) do
    fields
    |> Enum.reduce(changeset, fn field, acc ->
      acc = case acc.valid? do
        true -> validate_change(acc, field, fn field, value ->
          query = from p in Picture,
          where: hamming(p, field, value) > 0.9,
          select: %{
            id: p.id,
            filename: p.filename,
            possible_source: p.possible_source,
            dist_norm: hamming(p, field, value)
          }
          similar_pics = Repo.all(query)

          case similar_pics do
            [] -> []
            _ -> [{field, { "have similar images", similar_pics }}]
          end
        end
        )

        false -> acc
      end
    end)
  end
end
