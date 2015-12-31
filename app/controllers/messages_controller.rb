class MessagesController < ApplicationController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :log_params

  def index
  end

  def create
  end

  def update
  end

  def destroy
  end

  private

  def log_params
    Rails.logger.info params
  end
end
