defmodule Addict.Mailers.Mailgun do
  @moduledoc """
  Wrapper for Mailgun client that handles eventual errors.
  """
  require Logger
  use Mailgun.Client, domain: Application.get_env(:addict, :mailgun_domain),
                      key: Application.get_env(:addict, :mailgun_key)

  @doc """
  Sends an e-mail to a user. Returns a tuple with `{:ok, result}` on success or
  `{:error, status_error}` on failure.
  """
  def send_email_to_user(email, from, subject, html_body) do
    if Application.get_env(:addict, :mailgun_domain) == nil do
      Logger.debug "E-mail to #{email} not sent. Please configure mailgun_key and mailgun_domain ENV variables"
    else
      send_email(email, from, subject, html_body)
    end
  end


  def send_email(email, from, subject, html_body) do
    result = send_email to: email,
                 from: from,
                 subject: subject,
                 html: html_body

    case result do
      {:error, status, json_body} -> handle_error(email, status, json_body)
      _ -> {:ok, result}
    end
  end

  defp handle_error(email, status, json_body) do
    Logger.debug "Unable to send e-mail to #{email}"
    Logger.debug "status: #{status}"
    IO.inspect json_body

    {:error, to_string(status) }
  end

end
