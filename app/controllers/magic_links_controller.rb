class MagicLinksController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 5, within: 15.minutes, only: :create, with: -> { render json: { error: "Too many requests" }, status: :too_many_requests }

  def create
    user = find_or_create_user

    if user.persisted?
      magic_link = user.magic_links.new
      magic_link.generate_token
      magic_link.save!

      MagicLinkMailer.send_link(user, magic_link).deliver_later

      render inertia: "auth/CheckEmail", props: { email: user.email }
    else
      render inertia: "auth/SignIn", props: {
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def verify
    magic_link = MagicLink.find_by(token: params[:token])

    if magic_link.nil?
      redirect_to new_session_path, alert: "Invalid magic link"
    elsif !magic_link.valid_for_use?
      if magic_link.expired?
        redirect_to new_session_path, alert: "This magic link has expired"
      else
        redirect_to new_session_path, alert: "This magic link has already been used"
      end
    else
      magic_link.mark_as_used!
      start_new_session_for(magic_link.user)
      redirect_to app_root_path, notice: "Successfully signed in"
    end
  end

  private

  def find_or_create_user
    user = User.find_by(email: params[:email])
    return user if user

    # Create new account and user
    account = Account.create!(
      name: params[:account_name] || "My Account",
      subdomain: generate_subdomain(params[:email])
    )

    account.users.create!(
      email: params[:email],
      name: params[:name] || params[:email].split("@").first,
      role: :owner
    ).tap do |new_user|
      account.update!(owner: new_user)

      # Publish welcome event for new user
      ActiveSupport::Notifications.instrument(
        "lifecycle.welcome",
        user: new_user
      )
    end
  end

  def generate_subdomain(email)
    base = email.split("@").first.parameterize
    subdomain = base
    counter = 1

    while Account.exists?(subdomain: subdomain)
      subdomain = "#{base}-#{counter}"
      counter += 1
    end

    subdomain
  end
end
