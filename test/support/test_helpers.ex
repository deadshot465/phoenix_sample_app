defmodule SampleApp.TestHelpers do
  @spec user_fixture(map() | Keyword.t()) :: %SampleApp.Account.User{}
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "Some user",
        email: "example@example.com",
        password: "abc123",
        password_confirmation: "abc123"
      })
      |> SampleApp.Account.register_user()

    user
  end
end
