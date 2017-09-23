defmodule RumblWeb.Auth do
  import Plug.Conn
  import Comeonin.Bcrypt
  alias RumblWeb.User

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  # This plugin only tries to get a user_id from the session and
  # add the user to "assigns". It then passes through. The real
  # authentication happens when an action tries to get the user_id
  # from the session.
  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    user = user_id && repo.get(RumblWeb.User, user_id)
    assign(conn, :current_user, user)
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  def login_by_username_and_password(conn, username, password, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(User, username: username)

    cond do
      user && checkpw(password, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end
end
