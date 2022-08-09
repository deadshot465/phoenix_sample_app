defmodule SampleApp.Account do
  alias SampleApp.Repo
  alias SampleApp.Account.User

  def list_users do
    Repo.all(User)
  end

  def find_user(id), do: Repo.get(User, id)

  def find_user!(id), do: Repo.get!(User, id)

  def find_user_by(params), do: Repo.get_by(User, params)

  @spec change_user(%User{}) :: Ecto.Changeset.t()
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @spec change_registration(
          %SampleApp.Account.User{},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  def change_registration(%User{} = user, params) do
    User.registration_changeset(user, params)
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @spec remember_user(
          {map, map}
          | %{
              :__struct__ => atom | %{:__changeset__ => map, optional(any) => any},
              optional(atom) => any
            },
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: tuple
  def remember_user(user, attrs \\ %{}) do
    User.remember_changeset(user, attrs)
    |> then(fn {changeset, token} -> Tuple.append(Repo.update(changeset), token) end)
  end

  def authenticated?(user_id, remember_token) do
    user = find_user(user_id)

    cond do
      user && Pbkdf2.verify_pass(remember_token, user.remember_digest) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end

  def authenticate(email, pass) do
    user = find_user_by(email: email)

    cond do
      user && Pbkdf2.verify_pass(pass, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end
end
