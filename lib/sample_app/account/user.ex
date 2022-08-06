defmodule SampleApp.Account.User do
  use Ecto.Schema
  import Ecto.Changeset

  @email_regex ~r/^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/

  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :password_confirmation, :string, virtual: true
    field :remember_digest, :string
    field :remember_me, :boolean, virtual: true

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> validate_length(:name, min: 3, max: 50)
    |> validate_length(:email, min: 10, max: 255)
    |> validate_format(:email, @email_regex)
  end

  @spec registration_changeset(
          {map, map}
          | %{
              :__struct__ => atom | %{:__changeset__ => map, optional(any) => any},
              optional(atom) => any
            },
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation])
    |> validate_length(:password, min: 6, max: 100)
    |> validate_length(:password_confirmation, min: 6, max: 100)
    |> validate_confirmation(:password)
    |> put_password_hash()
  end

  def remember_changeset(user, attrs) do
    user
    |> cast(attrs, [:remember_me])
    |> validate_required([:remember_me])
    |> put_remember_digest()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Pbkdf2.hash_pwd_salt(password))

      _ -> changeset
    end
  end

  defp put_remember_digest(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{remember_me: true}} ->
        token = Pbkdf2.Base.gen_salt(format: :django, salt_len: 22)
        {put_change(changeset, :remember_digest, token |> Pbkdf2.hash_pwd_salt()), token}
      _ -> {changeset, ""}
    end
  end
end
